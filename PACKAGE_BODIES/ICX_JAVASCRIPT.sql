--------------------------------------------------------
--  DDL for Package Body ICX_JAVASCRIPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_JAVASCRIPT" as
/* $Header: ICXJSB.pls 120.0 2005/10/07 12:14:41 gjimenez noship $ */

--
  procedure open_script( version varchar2 default '1.1' ) is
  begin
    htp.p( '<SCRIPT LANGUAGE="JavaScript' || version || '">' );
    htp.p( '<!-- Comment out script for old browers' );
  end open_script;
  --
  procedure open_noscript is
  begin
    htp.p( '<NOSCRIPT>' );
  end open_noscript;
  --
  procedure close_script is
  begin
    htp.p( '//-->' );
    htp.p( '</SCRIPT>' );
  end close_script;
  --
  procedure close_noscript is
  begin
    htp.p( '</NOSCRIPT>' );
  end close_noscript;

  procedure move_list_element is
  begin
    htp.p( 'function moveListElement(fromList, toList, p_formname)' );
    htp.p( '{' );
    htp.p( '  idx = fromList.selectedIndex;' );
    htp.p( '  if ( idx == -1 )' );
    htp.p( '    return;' );
    htp.p( '  txt = fromList.options[idx].text;' );
    htp.p( '  val = fromList.options[idx].value;' );
    htp.p( '  if ( val == "" )' );
    htp.p( '    return;' );
    htp.p( '  for ( i = idx; i < fromList.length-1; i++ )' );
    htp.p( '  {' );
    htp.p( '    fromList.options[i].text = fromList.options[i+1].text;' );
    htp.p( '    fromList.options[i].value = fromList.options[i+1].value;' );
    htp.p( '  }' );
    htp.p( '  fromList.length = fromList.length - 1;' );
    htp.p( '  toList.options[toList.length] = new Option( txt, val, false, true );' );
    htp.p( '}' );
  end move_list_element;
--


  procedure copy_to_list is
  begin
    htp.p( 'function copyToList(fromList, toList, direction, p_formname)' );
    htp.p('{');
    htp.p('   for ( i = 0; i <= fromList.length-1;) {');
    htp.p('    if (fromList.options[i].selected) {');
    htp.p('        txt = fromList.options[i].text;');
    htp.p('        val = fromList.options[i].value;');
    htp.p('        if ( val != "" ) {' );
    htp.p('           // check if value is a spacer');
    htp.p('           if ( val != "spacer" ) {
                         if ( direction == "left" ) {
                            // remove from right and do not add on left
                            fromList.options[i]= null;
                         }
                         else {
                            // add to right but do not remove from left
                            fromList.options[i].selected = false;
                            toList.options[toList.length] = new Option( txt, val, false, true );
                            toList.options[toList.selectedIndex].selected = false;
                         }');
    htp.p('           }');
    htp.p('           else {  //only increment when not moving and deleting');
    htp.p('             // create a new row');
    htp.p('             toList.options[toList.length] = new Option( txt, val, false, true );');
    htp.p('             // added these lines');
    htp.p('             // removes from fromList and unselects item in toList');
    htp.p('             fromList.options[i]= null;');
    htp.p('             toList.options[toList.selectedIndex].selected = false;');
    htp.p('           }  //only increment when not moving and deleting');

    htp.p('        }');
    htp.p('    } else i++;  //only increment when not moving and deleting');
    htp.p('  }');
    htp.p('  deleteBlankRowIfNotEmpty(fromList);');
    htp.p('  deleteBlankRowIfNotEmpty(toList);');
-- Begin Bug 1853248
-- Changed below line from refresh(true) to refresh(false)
    htp.p('  navigator.plugins.refresh(false);');
-- End bug 1853248
    htp.p('}');
  end copy_to_list;
--
  procedure copy_all is
c_browser       varchar2(240);
  begin

   htp.p( 'function copyAll(fromList, toList, direction, p_formname) ');
   htp.p( '{' );
   htp.p('          indexofspacer = -1;');
   htp.p('                      spacerval = "";');
   htp.p('                      spacertxt = "";');
   htp.p('                      indexofitem = toList.length;');
   htp.p('          for ( i = 0; i <= fromList.length-1; i++ )');
   htp.p('                      {');
   htp.p('            txt = fromList.options[i].text; ');
   htp.p('            val = fromList.options[i].value;' );
   htp.p('            if ( val != "" ) ');
   htp.p('                            { ');
   htp.p('                if(direction != "left") ');
   htp.p('                {');
--               // check if we need to copy the spacer too
   htp.p('                  if ( val != "spacer") ');
   htp.p('                                      { ');
   htp.p(' toList.options[indexofitem] = new Option( txt, val, false, true ); ');
   htp.p('               toList.options[indexofitem].selected = false; ');
   htp.p('                                              indexofitem++; ');
   htp.p('                                       } ');
   htp.p('                                       else '); --// found a spacer
   htp.p('                                       { ');
   htp.p('                                              indexofspacer = i; ');
   htp.p('                                              spacerval = val; ');
   htp.p('                                              spacertxt = txt; ');
   htp.p('                                       }');
   htp.p('                 }');
   htp.p('                         }');
   htp.p('           }  ');
   htp.p('             if (indexofspacer != -1 && direction == "right" ) ');
 --// let the spacer be on the from list
   htp.p('                            fromList.length = 1;');
   htp.p('             else');
   htp.p('           if(direction == "left")');
   htp.p('             clearList(fromList); ');

   htp.p('           deleteBlankRowIfNotEmpty(toList);');
   htp.p('           unSelectAll(toList);');

    htp.p('          navigator.plugins.refresh(false); ');

     htp.p('}');

  end copy_all;

  procedure delete_list_element is
  begin
    htp.p( 'function deleteListElement(fromList)' );
    htp.p( '{' );
    htp.p( '  idx = fromList.selectedIndex;' );
    htp.p( '  if ( idx == -1 )' );
    htp.p( '    return;' );
    htp.p( '  for ( i = idx; i < fromList.length-1; i++ )' );
    htp.p( '  {' );
    htp.p( '    fromList.options[i].text = fromList.options[i+1].text;' );
    htp.p( '    fromList.options[i].value = fromList.options[i+1].value;' );
    htp.p( '  }' );
    htp.p( '  fromList.length = fromList.length - 1;' );
    htp.p( '}' );
  end delete_list_element;
--
  procedure select_all is
  begin
    htp.p( 'function selectAll(fromList)' );
    htp.p( '{' );
    htp.p( '  for ( i = 0; i <= fromList.length-1; i++ )' );
    htp.p( '    fromList.options[i].selected = true;' );
    htp.p( '  return true;' );
    htp.p( '}' );
  end select_all;
--
  procedure unselect_all is
  begin
    htp.p( 'function unSelectAll(fromList)' );
    htp.p( '{' );
    htp.p( '  for ( i = 0; i <= fromList.length-1; i++ )' );
    htp.p( '    fromList.options[i].selected = false;' );
    htp.p( '  return true;' );
    htp.p( '}' );
  end unselect_all;
--
  procedure clear_list is
  begin
    htp.p( 'function clearList(fromList)' );
    htp.p( '{' );
    htp.p( '  fromList.length = 0;' );
    htp.p( '}' );
  end clear_list;
--
-- append a value to a list, maintaining unique values in the list
  procedure append_to_list is
  begin
        htp.p( 'function appendToList(theValue, toList)' );
        htp.p( '{' );
        htp.p( '  if (theValue == "") return;' );
        htp.p( '  for (i=0;i<toList.length;i++)' );
        htp.p( '  {' );
        htp.p( '    if (toList.options[i].value == theValue)' );
        htp.p( '      return;' );
        htp.p( '  }' );
        htp.p( '  toList.options[toList.length] = new Option(theValue,theValue);' );
        htp.p( '}' );
  end append_to_list;
-- delete a given value from a select list
  procedure delete_from_list is
  begin
        htp.p( 'function deleteFromList(theValue, fromList)' );
        htp.p( '{' );
        htp.p( '  for (i=0;i<fromList.length;i++)' );
        htp.p( '  {' );
        htp.p( '    if (fromList.options[i].value == theValue)' );
        htp.p( '      fromList.options[i] = null;' );
        htp.p( '  }' );
        htp.p( '  history.go(0);' );
        htp.p( '}' );
  end delete_from_list;
--
  procedure swap is
  begin
    htp.p ('function swap(e1, e2)');
    htp.p ('{');
    htp.p ('  ttext = e1.text;');
    htp.p ('  tvalue = e1.value;');
    htp.p ('  e1.text = e2.text;');
    htp.p ('  e1.value = e2.value;');
    htp.p ('  e2.text = ttext;');
    htp.p ('  e2.value = tvalue;');
    htp.p ('} ');
  end swap;
--
  procedure move_element_up is
  begin
    htp.p(' function moveElementUp(toList, p_formname)
         {    // go through the list and get all selected items
              for ( i = 0; i <= toList.length-1; i++)
              { // if the item is selected then swap it
                if (toList.options[i].selected)
                {   // check if it is not the first item
                    if (i != 0)
                    {
                        swap(toList.options[i], toList.options[i - 1]);
                        toList.options[i - 1].selected = true;
                        toList.options[i].selected = false;
                    }
                }
              }
         }');
  end move_element_up;

--
  procedure move_element_top is
  begin
    htp.p(' function moveElementTop(toList, p_formname)
         {    // get the first item selected which needs to move to top
              iSelected = toList.selectedIndex;
              if (iSelected == 0)
                 return;
              // now run the moveup loop
              for ( iMoveTop = 1; iMoveTop <= iSelected; iMoveTop++)
                 moveElementUp(toList);
         }');
  end move_element_top;
--
  procedure move_element_down is
  begin
    htp.p(' function moveElementDown(toList, p_formname)
         {    // go through the list and get all selected items
              for ( i = toList.length-1; i >= 0; i--)
              { // if the item is selected then swap it
                if (toList.options[i].selected)
                {   // check if it is not the first item
                    if (i != toList.length-1)
                    {
                        swap(toList.options[i], toList.options[i + 1]);
                        toList.options[i + 1].selected = true;
                        toList.options[i].selected = false;
                    }
                }
              }
         }');
  end move_element_down;

--
  procedure move_element_bottom is
  begin
    htp.p(' function moveElementBottom(toList, p_formname)
         {    // get the last item selected which needs to move to bottom
              for ( i = 0; i <= toList.length-1; i++)
              { // if the item is selected then swap it
                if (toList.options[i].selected)
                    iSelected = i;
              }
              if (iSelected == toList.length-1)
                 return;
              iSelected = toList.length - 1 - iSelected;
              // now run the movedown loop
              for ( iMoveDown = 1; iMoveDown <= iSelected; iMoveDown++)
                 moveElementDown(toList);
         }');
  end move_element_bottom;


    procedure delete_blank_row is
  begin
    htp.p('function deleteBlankRowIfNotEmpty(toList)');
    htp.p('{');
    htp.p('   var idx = -1;');
    htp.p('   var val = "";');
    htp.p('// find a blank row in table ');
    htp.p('   for (i = 0; i < toList.length; i++){ ');
    htp.p('        val = toList.options[i].value;');
    htp.p('        if (val == "") {');
    htp.p('           idx = i;');
    htp.p('           break;');
    htp.p('        }');
    htp.p('   } ');
    htp.p('   if (idx >= 0 && (toList.length > 1))');
    htp.p('      toList.options[idx] = null;');
    htp.p('}');
  end delete_blank_row;

  procedure show_main_help
  as
  begin
     open_script;

     htp.p('function show_main_help() {');
     htp.p('   newWindow = window.open("' ||
        'pob_help_menu_tree.show_tree' ||
        '", "HelpPage", "menubar=1,toolbar=yes,scrollbars=1,resizable=1,width=600,height=400");');
     htp.p('}');

     close_script;

  end show_main_help;

  procedure show_context_sens_help
  as
  begin
     open_script;

     htp.p('function show_context_sens_help(helpFileName) {');
     htp.p('   newWindow = window.open("' ||
       'pob_help_renderer.render_context_sensitive' ||
       '?the_filename=" + helpFileName' ||
        ', "HelpPage", "menubar=1,toolbar=yes,scrollbars=1,resizable=1,width=600,height=400");');
     htp.p('}');

     close_script;

  end show_context_sens_help;

end icx_javascript;

/
