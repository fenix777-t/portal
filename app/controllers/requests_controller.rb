class RequestsController < ApplicationController
  def index

  end

  def upload_xsd

	require 'rexml/document'

	doc = REXML::Document.new(params[:upload]['datafile'].read)

	doc.root.elements.each do |el|
		if el.name == "element" then
			name = el.attributes['name']
			puts 'name=' + name
			
			# это не запрос, а параметр указанного типа
			if el.attributes['type'] then
				tname = el.attributes['type']
				x = Param.find_by(name: name)

				if x == nil then
					x = Param.new(name: name, tname: tname)
					x.save
				elsif
					x.tname = tname
					x.save
				end
			# все остальное считаем запросами
			elsif
				if el.elements['xs:annotation'] != nil then
					documentation = el.elements['xs:annotation'].elements['xs:documentation'].text
				end

				args = el.elements['xs:complexType'].to_s

				req = Request.find_by(name: name)

				if req == nil then
					req = Request.new(name: name, documentation: documentation, args: args)
					req.save
				elsif
					req.documentation = documentation
					req.args = args
					req.save
				end
			end
		end

		if el.name == "simpleType" then
			name = el.attributes['name']
			title = ''
			title = el.elements['xs:annotation'].elements['xs:documentation'].text if el.elements['xs:annotation']

			val = ''
			if el.elements['xs:restriction'] != nil then
				val += '</br> Базовый тип ' + el.elements['xs:restriction'].attributes['base'] if el.elements['xs:restriction'].attributes['base']

				val += '</br> Рег. выражение:' + el.elements['xs:restriction'].elements['xs:pattern'].attributes['value'] if el.elements['xs:restriction'].elements['xs:pattern']

				val += '</br> Мин. значение:' + el.elements['xs:restriction'].elements['xs:minInclusive'].attributes['value'] if el.elements['xs:restriction'].elements['xs:minInclusive']

				val += '</br> Макс. значение:' + el.elements['xs:restriction'].elements['xs:maxInclusive'].attributes['value'] if el.elements['xs:restriction'].elements['xs:maxInclusive']

				val += '</br> Мин. длина:' + el.elements['xs:restriction'].elements['xs:minLength'].attributes['value'] if el.elements['xs:restriction'].elements['xs:minLength']

				val += '</br> Макс. длина:' + el.elements['xs:restriction'].elements['xs:maxLength'].attributes['value'] if el.elements['xs:restriction'].elements['xs:maxLength']
			end

			t = Type.find_by(name: name)

			if t == nil then
				t = Type.new(name: name, title: title, val: val)
				t.save
			elsif
				t.val = val
				t.save
			end
		end

		#типы данных с параметрами (complexType)
		if el.name == "complexType" then
			name = el.attributes['name']
			title = ''
			title = el.elements['xs:annotation'].elements['xs:documentation'].text if el.elements['xs:annotation']

			val = ''
			args = el.to_s

			t = Type.find_by(name: name)

			if t == nil then
				t = Type.new(name: name, title: title, val: val, args: args)
				t.save
			elsif
				t.val = val
				t.args = args
				t.save
			end
		end

	end

  end

  def list
	text = params[:text]

	a = nil

	if text != nil then
		a = Request.where('name LIKE ? OR documentation LIKE ?', '%' + text + '%', '%' + text + '%').order(name: :ASC)
	else
		a = Request.all.order(name: :ASC)
	end


	@requests = a
  end

  def erase
	Request.delete_all
	Type.delete_all
	Param.delete_all

	redirect_to controller: 'requests', action: 'list'
  end

  def seq2assoc(seq)

	a = []

	if seq == nil then
		return a
	end

	seq.elements.each do |e|

		if e.name == "element" then
			name = ''
			text = ''
			type = ''

			if e.attributes['ref'] != nil then
				name = e.attributes['ref']

				x = Request.find_by(name: name)

				if x != nil then
					text = '<a href="/list/' + x.id.to_s + '">' + name + '</a>'
				elsif
					text = '<a href="#">' + name + '</a>'
				end

				type = 'Структура'
			elsif
				name = e.attributes['name']
				if e.elements['xs:annotation'] != nil then
					text = e.elements['xs:annotation'].elements['xs:documentation'].text
				end
				type = e.attributes['type']

				x = Type.find_by(name: type)

				if x != nil then
					type = '<a href="/types/' + x.id.to_s + '">' + type + '</a>'
				end

			end

			minOccurs = e.attributes['minOccurs']
			maxOccurs = e.attributes['maxOccurs']

			minOccurs = "..." if minOccurs == nil
			maxOccurs = "..." if maxOccurs == nil
			maxOccurs = "&infin;".html_safe if maxOccurs == "unbounded"


			childs = []

			if e.elements['xs:complexType'] != nil then
				childs = seq2assoc(e.elements['xs:complexType'].elements['xs:sequence'])
			elsif e.elements['xs:sequence'] != nil then
				childs = seq2assoc(e.elements['xs:sequence'])
			end

			a.push({name: name, text: text, type: type, minOccurs: minOccurs, maxOccurs: maxOccurs, childs: childs})

		elsif e.name = "sequence" then
			a += seq2assoc(e)
		end
	end


	return a
  end

  def show
	@request = Request.find(params[:id])

	require 'rexml/document'
	doc = REXML::Document.new('<xs:schema version="1.0" xmlns:xs="w3.org/2001/XMLSchema">' + @request.args + '</xs:schema>')


	a = seq2assoc(doc.elements['//xs:sequence'])

	@items = a
  end

  def tshow
	@i = Type.find(params[:id])

	require 'rexml/document'
	doc = REXML::Document.new('<xs:schema version="1.0" xmlns:xs="w3.org/2001/XMLSchema">' + @i.args + '</xs:schema>')


	a = seq2assoc(doc.elements['//xs:sequence'])

	@items = a
  end


  def plist
	a = Param.all.order(name: :ASC)

	a.each do |i|
		x = Type.find_by(name: i.tname)
		if x then
			i.tname = '<a href="/types/' + x.id.to_s + '">' + i.tname + '</a>'
		end
	end

	@items = a
  end

  def types
	a = Type.all.order(name: :ASC)

	@items = a
  end

end
