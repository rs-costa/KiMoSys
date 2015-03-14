# KiMoSys - web-based platform for Kinetic Models of biological Systems.
# Copyright (C) 2013-2013 Rafael Costa

# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; version 2
# of the License.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of

# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software


# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
  $('form').on 'click', '.remove_fields', (event) ->
    $(this).prev('input[type=hidden]').val('1')
    $(this).closest('fieldset').hide()
    event.preventDefault()

  $('form').on 'click', '.add_fields', (event) ->
    time = new Date().getTime()
    regexp = new RegExp($(this).data('id'), 'g')
    $(this).before($(this).data('fields').replace(regexp, time))
    event.preventDefault()

  find_duplicates = ->
    if $("#duplicate").length == 0
      return null
    params = "manuscript_title=" + $("#associated_model_manuscript_title").prop("value") + "&pubmed_id=" + $("#associated_model_pubmed_id").prop("value")
    $.ajax({
      type: "get"
      url: $("#duplicate").data().url
      data: params
      success: (data)->
         
      error: (data)->
        $('#duplicate').empty().append('Sorry, an error has occured finding duplicates. You can still create a new model')  
    })

  $('form').on 'change', '#associated_model_pubmed_id', (event) =>
    if $("#duplicate").data().newRecord
      find_duplicates()
  
  $('form').on 'change', '#associated_model_manuscript_title', (event) =>
    if $("#duplicate").data().newRecord
      find_duplicates()  
  
  if $("#duplicate").length > 0 && $("#duplicate").data().newRecord
    find_duplicates()