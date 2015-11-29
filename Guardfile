ignore /^MathJax/
ignore /\.\#.*/
guard :shell do
  watch(/(.*)\.md$/) do |f| 
    puts `./Build #{f[1] + '.pdf'}`
  end
  # watch(/(.*)\.org$/) do |f|
  #   puts `./Build #{f[1] + '.md'}`
  # end
  # watch(/(.*)\.slide\.md$/) do |f|
  #   puts `./Build #{f[1] + '.html'}`
  #   puts `./Build #{f[1] + '.pdf'}`
  # end
end

guard 'livereload' do
  watch(%r{.*\.(pdf|html|svg)})
end
