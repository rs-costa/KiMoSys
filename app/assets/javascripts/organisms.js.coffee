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
@tooltips = ()->

  $('.tooltip').each () ->
    $(this).qtip {
      content: {
        text: $(this).find('.tooltiptext')
        overwrite: false
      }
      style: {
        width: '400px';
      }
      position: {
        my: 'bottom left',
        at: 'top left',
        adjust: {
          method: 'shift flip'
        },
        #viewport: $('#content')
        viewport: $(window)
      },
    }
  $('.tooltip-info').each () ->
    $(this).qtip {
      content: {
        text: $(this).find('.tooltiptext')
        overwrite: false
        button: true
      }
      style: {
        width: '700px';
        classes: 'qtip-light qtip-shadow qtip-rounded'
      }
      show: {
        event: 'click'
        modal: { # Requires Modal plugin
            on: true, # No modal backdrop by default
            effect: true, # Mimic show effect on backdrop
            blur: true, # Hide tooltip by clicking backdrop
            escape: true # Hide tooltip when Esc pressed
        }
      }
      hide: {
        event: 'unfocus'
      }
      position: {
        my: 'bottom left',
        at: 'top right',
        adjust: {
          method: 'shift flip'
        },
        #viewport: $('#content')
        viewport: $(window)
      },
    }


@previews = () ->
  $( ".pop_modal" ).qtip {
    overwrite: false,
    content: {
      #title: '(this will close automatically after 5 seconds)',
      button: 'Close',
      text: () ->
        id=$(this).parents('tr').data('organism_id')
        $("#pop_me_"+id).html()

    },
    style: {
      classes: 'qtip-light qtip-rounded qtip-shadow'
    },
    show: {
      event: 'click',
      delay: 10,
      target: false
    },
    hide: {
        event: 'click sort', #mouseleave
        #delay: 5000,
        leave: 'window',
        fixed: true
    },
    position: {
      my: 'top right',
      at: 'bottom left',
      adjust: {
        method: 'shift none'
      },
      #viewport: $('#content')
      viewport: $(window)
    },
    events: {
      render: (event, api) ->
        $(this).find('.qtip-content table.delay_table').dataTable( {
          "fnDrawCallback": ( oSettings ) ->
            tooltips()
        } )
      visible: (event, api) ->
        api.elements.target.parents('tr').children('td').css('padding-bottom',api.elements.tooltip.height()+10)
        $('.qtip').qtip('api').reposition(null,false)
      hidden: (event, api) ->
        api.elements.target.parents('tr').children('td').css('padding-bottom', 0)
        $('.qtip').qtip('api').reposition(null,false)

      #,focus: (event, api) ->
      #  api.set('position.adjust.y', -5);
      #,blur: (event, api) ->
      #  api.set('position.adjust.y', 0);
    }
  }

jQuery ->


  $('#organismsTable, .format_table').dataTable( {
    "fnDrawCallback": ( oSettings ) ->
      $('.qtip').qtip('hide')
      tooltips()
      previews()
      $('.dataTables_filter input').prop("placeholder", "enter search terms")
  } )

  $( "#organism_execution" ).datepicker()

  $('#organism_type_param').change ->
    if @.value == ""
      $(".hide_when_type").show()
    else
      $(".hide_when_type").hide()
    $( ".menu_" + @.value).show()
    $( ".subpoint:not(.menu_" + @.value + ")").hide()
