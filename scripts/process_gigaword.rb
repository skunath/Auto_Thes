# encoding: utf-8
require 'find'
require 'rubygems'
require 'nokogiri'
require 'active_record'


# DB Setup

ActiveRecord::Base.establish_connection(
:adapter => "mysql2",
:host => "localhost",
:username => "root",
:database => "chinese_thes"
)

class Cedict < ActiveRecord::Base
  set_table_name "cedict"
end

class Sentence < ActiveRecord::Base
end

# scan and get a list of files we are interested in
files_to_process = []
Find.find('/research/chinese_thes/data/gigaword/data/') do |f| 
  if (!f.include?("gz") && !f.include?("DS"))&& File.file?(f)
    files_to_process<< f
  end 
end

class GigaDoc < Nokogiri::XML::SAX::Document
  attr_accessor :paragraphs
  
  def initialize
    @paragraphs = []
    @text = ""
    @in_p = false
  end
  
  def characters string
    if @in_p
      @text += string
    end
  end
  
  def start_element name, attrs = []
    if name == "P"
      @in_p = true
    end
  end

  def end_element name
    if name == "P" && @in_p
      @paragraphs << @text
      @text = ""
      @in_p = false
    end
  end
end


def process_a_file(filename)
  # use this object to grab the result of the parse...
  giga_doc = GigaDoc.new
  parser = Nokogiri::XML::SAX::Parser.new(giga_doc)
  # Send some XML to the parser
  file_reading = File.open(filename)
  
  # screw with XML to make it wonderful... basically add total open/close tags
  prepped_file = "<MAINFILE>" + file_reading.read() + "</MAINFILE>"
   
  parser.parse(prepped_file)
  

  # now we proces another round and put the sentences into their own records
  for sentence in giga_doc.paragraphs
    psentence = sentence.gsub("\n","")
    real_sentences = psentence.split("。")
    
    for final_sentence in real_sentences
      db_sentence = Sentence.new()
      db_sentence.sentence = final_sentence
      db_sentence.source_file = filename
      db_sentence.save  
    end 
    
    
  end
  

end


for filename in files_to_process
  process_a_file(filename)  
end

