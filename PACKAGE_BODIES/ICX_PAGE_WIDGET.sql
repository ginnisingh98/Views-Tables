--------------------------------------------------------
--  DDL for Package Body ICX_PAGE_WIDGET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_PAGE_WIDGET" as
/* $Header: ICXWIGB.pls 120.0 2005/10/07 12:21:43 gjimenez noship $ */

   function arraytocsv( p_array in icx_api_region.array ) return varchar2
   as
      v_csv varchar2(10000) := '';
   begin
      if p_array.count = 0 then
         return '';
      end if;
      for i in 1 .. p_array.count loop
         v_csv := v_csv || ',' || p_array(i);
      end loop;
      return substr( v_csv, 2 );
   exception
      when others then
         htp.p(SQLERRM);
   end;

   -- Required for padding strings with non-breaking spaces. Used in buildselectboxes
   function nbsppad( p_string in varchar2, p_length in number ) return varchar2
   as
   begin
      if p_string is null then
         return(replace( rpad( ' ', p_length-1), ' ', '&nbsp;&nbsp;' ));
      else
         return(replace( rpad( p_string, p_length-length(p_string)), ' ', '&nbsp;&nbsp;' ));
      end if;
   exception
   when others then
        raise NBSPPAD_EXCEPTION;
   end nbsppad;


   procedure buildselectboxes(
      p_leftnames  in icx_api_region.array,      --- list of names of available providers:portlets
      p_leftids    in icx_api_region.array,      --- list of ids of available provider:portletids
      p_rightnames in icx_api_region.array,      --- list of names of selected providers:portlets
      p_rightids   in icx_api_region.array,      --- list of ids of selected providers:portletids:instanceids
      p_pageid     in number,
      p_regionid   in number
      )
   as
      l_label varchar2(80);
   begin
      htp.tableRowOpen;
      htp.prn( '<td rowspan=4 align="left">' );

      htp.formSelectOpen( 'p_leftselect', nsize => 8, cattributes=>'multiple');
      for i in 1 .. p_leftids.count loop
         -- if added to prevent truncation of strings longer than 32 from the rpad function
         -- mputman 1420084
         IF length(p_leftnames(i))<32 THEN
         htp.formSelectOption( replace( rpad( p_leftnames(i), 32), ' ', '&nbsp;&nbsp;' ), cattributes => 'VALUE="'||p_leftids(i)||'"' );
         ELSE
         htp.formSelectOption( replace( p_leftnames(i), ' ', '&nbsp;&nbsp;' ), cattributes => 'VALUE="'||p_leftids(i)||'"' );
         END IF;
      end loop;

      if p_leftids.count = 0 then
         htp.formSelectOption( nbsppad( null, 32 ), cattributes => 'VALUE=""' );
      end if;
      htp.formSelectClose;
      htp.prn( '</td>' );

      select ATTRIBUTE_LABEL_LONG
      into   l_label
      from   AK_ATTRIBUTES_VL
      where  ATTRIBUTE_CODE = 'CSI_SHTL_MOVEALL';

      htp.tableData( '<A HREF="javascript:copyAll(document.addPlugdlg.p_leftselect,document.addPlugdlg.p_rightselect,''right'', ''addPlugdlg'');">' ||
             '<img src=' || '/OA_MEDIA/moverightall.gif' ||
                ' align=bottom border=0 alt="'|| l_label || '">' ||
             '</A>' );

      htp.prn( '<td rowspan=4 align="left">' );
      htp.formSelectOpen('p_rightselect', nsize => 8, cattributes=>'multiple');
      for i in 1 .. p_rightids.count loop
         -- if added to prevent truncation of strings longer than 32 from the rpad function
         -- mputman 1420084
         IF lengthb(p_rightnames(i))<32 THEN
            htp.formSelectOption( replace( rpad( p_rightnames(i), 32), ' ', '&nbsp;&nbsp;' ), cattributes => 'VALUE="'||p_rightids(i)||'"' );
         ELSE
            htp.formSelectOption( replace( p_rightnames(i), ' ', '&nbsp;&nbsp;' ), cattributes => 'VALUE="'||p_rightids(i)||'"' );
         END IF;
      end loop;
      if p_rightids.count = 0 then
         htp.formSelectOption( nbsppad( null, 32 ), cattributes => 'VALUE=""' );
      end if;
      htp.formSelectClose;


      htp.formHidden( 'p_selectedlist', arraytocsv(p_rightids));
      htp.formHidden( 'p_region_id', p_regionid);
      htp.formHidden( 'p_page_id', p_pageid);
      htp.prn( '</td>' );

      select ATTRIBUTE_LABEL_LONG
      into   l_label
      from   AK_ATTRIBUTES_VL
      where  ATTRIBUTE_CODE = 'JTFB_ADMIN_TOP';

      htp.tableData( '<A HREF="javascript:moveElementTop(document.addPlugdlg.p_rightselect, ''addPlugdlg'');">' ||
         '<img src= /OA_MEDIA/movetop.gif' || ' align=bottom border=0 alt="'||
              l_label || '">' ||
         '</A>' );
      htp.tableRowClose;

      htp.tableRowOpen;

      select ATTRIBUTE_LABEL_LONG
      into   l_label
      from   AK_ATTRIBUTES_VL
      where  ATTRIBUTE_CODE = 'CSI_SHTL_MOVE';

      htp.tableData( '<A HREF="javascript:copyToList(document.addPlugdlg.p_leftselect,document.addPlugdlg.p_rightselect,''right'', ''addPlugdlg'');">' ||
         '<img src= /OA_MEDIA/moveright.gif' || ' align=bottom border=0 alt="'||
              l_label || '">' ||
         '</A>' );

      select ATTRIBUTE_LABEL_LONG
      into   l_label
      from   AK_ATTRIBUTES_VL
      where  ATTRIBUTE_CODE = 'BIS_UP';

      htp.tableData( '<A HREF="javascript:moveElementUp(document.addPlugdlg.p_rightselect, ''addPlugdlg'');">' ||
         '<img src= /OA_MEDIA/moveup.gif' || ' align=bottom border=0 alt="'||
              l_label || '">' ||
         '</A>' );
      htp.tableRowClose;

      htp.tableRowOpen;

      select ATTRIBUTE_LABEL_LONG
      into   l_label
      from   AK_ATTRIBUTES_VL
      where  ATTRIBUTE_CODE = 'CSI_SHTL_REMOVE';

      htp.tableData( '<A HREF="javascript:copyToList(document.addPlugdlg.p_rightselect,document.addPlugdlg.p_leftselect,''left'', ''addPlugdlg'');">' ||
             '<img src= /OA_MEDIA/moveleft.gif' || ' align=bottom border=0 alt="'||
                  l_label || '">' ||
             '</A>' );

      select ATTRIBUTE_LABEL_LONG
      into   l_label
      from   AK_ATTRIBUTES_VL
      where  ATTRIBUTE_CODE = 'BIS_DOWN';

      htp.tableData( '<A HREF="javascript:moveElementDown(document.addPlugdlg.p_rightselect, ''addPlugdlg'');">' ||
         '<img src= /OA_MEDIA/movedown.gif' || ' align=bottom border=0 alt="'||
              l_label || '">' ||
         '</A>' );
      htp.tableRowClose;

      htp.tableRowOpen;

      select ATTRIBUTE_LABEL_LONG
      into   l_label
      from   AK_ATTRIBUTES_VL
      where  ATTRIBUTE_CODE = 'CSI_SHTL_REMOVEALL';

      htp.tableData( '<A HREF="javascript:copyAll(document.addPlugdlg.p_rightselect,document.addPlugdlg.p_leftselect,''left'', ''addPlugdlg'');">' ||
             '<img src= /OA_MEDIA/moveleftall.gif' || ' align=bottom border=0 alt="'||
                  l_label || '">' ||
             '</A>' );

      select ATTRIBUTE_LABEL_LONG
      into   l_label
      from   AK_ATTRIBUTES_VL
      where  ATTRIBUTE_CODE = 'JTFB_ADMIN_BOTTOM';

      htp.tableData( '<A HREF="javascript:moveElementBottom(document.addPlugdlg.p_rightselect, ''addPlugdlg'');">' ||
         '<img src= /OA_MEDIA/movebottom.gif' || ' align=bottom border=0 alt="'||
              l_label || '">' ||
         '</A>' );
      htp.tableRowClose;
   exception
   when others then
        raise BUILDSELECTBOXES_EXCEPTION;
   end buildselectboxes;

end icx_page_widget;

/
