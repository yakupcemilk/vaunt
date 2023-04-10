module vaunt

import json
import net.urllib

// 			Generate Block Html
// =======================================

struct Block {
	data string
pub:
	id         string
	block_type string [json: 'type']
}

fn generate(data string) string {
	blocks := json.decode([]Block, data) or { []Block{} }

	mut html := ''

	for block in blocks {
		html += match block.block_type {
			'heading' {
				generate_heading(block)
			}
			'paragraph' {
				generate_paragraph(block)
			}
			'linkTool' {
				generate_link(block)
			}
			'image' {
				generate_image(block)
			}
			'embed' {
				generate_embed(block)
			}
			'quote' {
				generate_quote(block)
			}
			'table' {
				generate_table(block)
			}
			'code' {
				generate_code(block)
			}
			else {
				''
			}
		}
	}
	return html
}

struct HeadingData {
pub:
	text  string
	level int
}

fn generate_heading(block &Block) string {
	data := json.decode(HeadingData, block.data) or { HeadingData{} }
	if data.level == 1 {
		return $tmpl('./templates/blocks/h1.html')
	} else if data.level == 2 {
		return $tmpl('./templates/blocks/h2.html')
	} else if data.level == 3 {
		return $tmpl('./templates/blocks/h3.html')
	} else {
		return ''
	}
}

struct ParagraphData {
pub:
	text string
}

fn generate_paragraph(block &Block) string {
	data := json.decode(ParagraphData, block.data) or { ParagraphData{} }
	return $tmpl('./templates/blocks/p.html')
}

fn generate_link(block &Block) string {
	data := json.decode(LinkData, block.data) or { LinkData{} }
	url := urllib.parse(data.link) or { urllib.URL{} }
	anchor := '${url.scheme}://${url.host}'

	return $tmpl('./templates/blocks/link.html')
}

struct ImageData {
pub:
	caption string
	file    map[string]string
}

fn generate_image(block &Block) string {
	data := json.decode(ImageData, block.data) or { ImageData{} }

	mut url := data.file['url']
	// check if image is local or not
	if url.starts_with('http://127.0.0.1') || url.starts_with('http://localhost') {
		url_s := urllib.parse(data.file['url']) or { urllib.URL{} }
		url = url_s.path
	}

	img_alt := if data.caption != '' { '[${data.caption}]' } else { '[image]' }
	return $tmpl('./templates/blocks/img.html')
}

struct EmbedData {
pub:
	service string
	source  string [skip]
	embed   string
	width   int
	height  int
	caption string
}

fn generate_embed(block &Block) string {
	data := json.decode(EmbedData, block.data) or { EmbedData{} }
	return $tmpl('./templates/blocks/embed.html')
}

struct QuoteData {
pub:
	text    string
	caption string
}

fn generate_quote(block &Block) string {
	data := json.decode(QuoteData, block.data) or { QuoteData{} }
	return $tmpl('./templates/blocks/quote.html')
}

struct TableData {
pub mut:
	with_headings bool       [json: withHeadings]
	content       [][]string
}

fn generate_table(block &Block) string {
	mut data := json.decode(TableData, block.data) or { TableData{} }

	mut table_headers := []string{}
	if data.with_headings {
		table_headers = data.content[0]
		data.content.delete(0)
	}

	table_rows := data.content

	return $tmpl('./templates/blocks/table.html')
}

struct CodeData {
	code string
pub:
	language string
	html     string
}

fn generate_code(block &Block) string {
	mut data := json.decode(CodeData, block.data) or { CodeData{} }

	return $tmpl('./templates/blocks/code.html')
}