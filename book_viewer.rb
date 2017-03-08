require 'sinatra'
require 'sinatra/reloader'
require 'pry'
require 'tilt/erubis'

helpers do
	def in_paragraphs(chapter)
		chapter.split("\n\n").each_with_index.map do |paragraph, index|
			"<p id=#{index}>" + "#{paragraph}" + "</p>"
		end
	end
end

before do
	@contents = File.readlines('data/toc.txt')
end

get '/' do
	@title = 'The Adventures of Sherlock Holmes'

	erb :home
end

get '/chapters/:number' do
	content_type :text
	@num = params[:number].to_i
	chapter_name = @contents[@num - 1]
	@title = "Chapter #{@num} - #{chapter_name}"
	@chapter = File.read("data/chp#{@num}.txt")

	erb :chapters
end

def each_chapter
	@contents.each_with_index do |name, number|
		chapter = File.read("data/chp#{number + 1}.txt")

		yield number + 1, name, in_paragraphs(chapter)
	end
end

def matching_paragraphs(contents)
	contents.select { |paragraph| paragraph.include? @query }
end

def matching_chapters
	results = []
	return results unless @query

	each_chapter do |number, name, contents|
		paragraphs = matching_paragraphs(contents)
		results << { number: number, name: number, text: paragraphs } if !paragraphs.empty?
	end

	results
end

get '/search' do
	#content_type :text
	@query = params[:query]
	@results = matching_chapters if @query
	
	erb :search
end

not_found do
	redirect '/'
end