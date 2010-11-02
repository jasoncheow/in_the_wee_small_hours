require 'rubygems'
require 'sinatra'
require 'redcloth'

TIMESTAMP_REGEXP = /(\d{4})(\d{2})(\d{2})_(\d{2})(\d{2})(\d{2})/

helpers do
  def format_datetime(datetime)
    datetime.strftime("%a, %d %b, %l:%M %p").sub(/^0/, "")
  end
end

get '/' do
  slugs = Dir['entries/*.textile'].collect {|file| file.gsub(/(^entries\/|\.textile$)/, '')}
  @entries = slugs.inject([]) do |entries, slug|
    if slug =~ TIMESTAMP_REGEXP
      entries << {:slug => slug, :datetime => Time.local($1, $2, $3, $4, $5, $6)}
    end
    entries
  end
  @entries.reverse!
  @entries_grouped_by_month = @entries.inject([]) do |groups, article|
    month = Time.local(article[:datetime].year, article[:datetime].month, 1)
    previous_group = groups.find {|group| group[:month] == month}
    if previous_group
      previous_group[:entries] << article
    else
      groups << {:month => month, :entries => [article]}
    end
    groups
  end
  erb :index
end

get '/:slug' do
  if params[:slug] =~ TIMESTAMP_REGEXP
    @datetime = Time.local($1, $2, $3, $4, $5, $6)
    content = RedCloth.new(File.read("entries/#{params[:slug]}.textile")).to_html
    content += "<hr /><p><a href=\"/\">Back</a></p>"
    erb content
  else
    raise Sinatra::NotFound
  end
end
