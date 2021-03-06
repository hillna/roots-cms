define ['marionette', 'jquery', 'templates', 'underscore', 'marked', 'pen', 'html_md', 'dropzone', 'pen_markdown'], (Marionette, $, templates, _, marked, Pen, md, Dropzone) ->
  class ContentEdit extends Marionette.ItemView
    template: templates.content_edit

    ui:
      'content': '.contents'
      'data': '.data input'
      'back': '.back'
      'upload': '.upload'
      'upload_area': '.upload-area'
      'message': '.message'
      'modal': '.modal'

    events:
      'click .save': 'save'
      'click .open-commit-modal': 'open_modal'
      'click .close': 'close_modal'
      'click .commit': 'commit'
      'click .back': 'go_back'

    templateHelpers: ->
      content_to_html: (-> marked(@model.get('content'))).bind(@)
      category: (-> @category_display()).bind(@)

    onRender: ->
      @ui.modal.easyModal()
      new Pen
        editor: @ui.content[0]
        list: [
          'blockquote', 'h2', 'h3', 'p', 'insertorderedlist', 'insertunorderedlist',
          'indent', 'outdent', 'bold', 'italic', 'underline', 'createlink', 'inserthtml'
        ]
        debug: true
        inserthtml: "<span class='upload-area' contenteditable='false'></span>"
        inserthtml_cb: ->
          upload = $('.upload-area')[0]
          $(upload).attr('contenteditable', false)
          drop = new Dropzone(upload, { url: '/api/upload_image' })
          drop.on 'success', (file, res) ->
            $('.upload-area').replaceWith("<img src=\"#{res.url}\"/>")


    get_data: ->
      _.reduce @ui.data, (data, el) ->
        data[$(el).attr('name')] = $(el).val()
        return data
      , {}

    category_display: ->
      cats = @model.get('id').split('/')
      cats.pop()
      cats.join('/')

    save: ->
      modified_content = md(@ui.content.html())
      @model.set('content', modified_content)
      @model.set('data', @get_data())
      @model.save()
      @render()

    commit: ->
      message = @ui.message.val()
      @save()
      $.post('/api/commit', {id: @model.id, message: message})
        .done (data) ->
          alert("successfully committed \"#{data}\"")

    open_modal: ->
      @ui.modal.trigger('openModal')

    close_modal: ->
      @ui.modal.trigger('closeModal')
