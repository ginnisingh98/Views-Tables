--------------------------------------------------------
--  DDL for Package Body BEN_EXT_XML_WRITE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EXT_XML_WRITE" as
/* $Header: benxxmlw.pkb 120.5.12010000.2 2008/08/05 15:02:37 ubhat ship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation                  |
|			   Redwood Shores, California, USA                     |
|			        All rights reserved.	                         |
+==============================================================================+
Name:
    Extract XML Write Process.
Purpose:
    This process reads records from the ben_ext_rslt_dtl table and writes them
    to a xml output file.
History:
     Date             Who        Version    What?
     ----             ---        -------    -----
     17 Apr 2003      tjesumic   115.0      Created Write Xml File
     17 Apr 2003      tjesumic   115.0      NOCOPY added
     22 Apr 2003      tjesumic   115.2      maxline is fixed
     22 Apr 2003      tjesumic   115.2      character set is changed to utf-8
     13 May 2003      tjesumic   115.4      XML user defined tag added
     14 May 2003      tjesumic   115.4      new attribute ext_rec_person id added ,
                                            the record is relatively refered in xsl
     14 may 2003      tjesumic   115.6      xsl and xsd files created on the user defined name
     16 may 2003      tjesumic   115.7      nonamespace used for schema
     28 may 2003      tjesumic   115.8      for default tags lookup value are used
     29 may 2003      tjesumic   115.9      check_sql error is fixed by spiliting
     29 may 2003      tjesumic   115.9      check_sql error is fixed by spiliting
     29 may 2003      tjesumic   115.11      complex type 'All' changed to 'choice'
     08 Aug 2003      tjesumic   115.12      Element Level Hide Flag is not displayed
     25 Aug 2004      tjesumic   115.13      xdo integeration
     08 Nov 2004      tjesumic   115.14      ext_xml_encode added
     15 dec 2004      tjesumic   115.15      ext_rcd_in_file_id adeded to validation
     15 Jan 2005      tjesumic   115.16      Hard coding charactset changed by
                                             getting the value from profile ICX_CLIENT_IANA_ENCODING
                                             XML grouped by the record low level for
                                             PDF format
     27-Jan-2005      tjesumic   115.17      when there is header and trailer  pdf format fails
     01-Feb-2005      tjesumic   115.18      300 elements allowed in  a record
     04-Mar-2005      tjesumic   115.19      XDO is called for all the type except 'X'ml
     22-Mar-2005      tjesumic   115.20      sub header and sub trailer added for xml creation
     22-Mar-2005      tjesumic   115.22      version 115.20 brought forward
     08-Jun-2005      tjesumic   115.23      pennserver extract  enhancment
     30-Nov-2005      tjesumic   115.24      fnd_concurrent_request table updted with output file
     06-Dec-2005      tjesumic   115.25      cm_display
     09-Dec-2005      tjesumic   115.26      new parameter p_source added
     14-MAr-2007      tjesumic   115.27      xml tag added for xdo ouputs
     26-Feb-2008      vkodedal   115.28      c_per_info modified #6838751
*/
-----------------------------------------------------------------------------------
--
g_package              varchar2(30) := ' ben_ext_xml_write.';
--
g_file_tag           ben_ext_dfn.xml_tag_name%Type ;
g_dfn_tag            ben_ext_dfn.xml_tag_name%Type ;
g_rcd_tag_tbl        BEN_EXT_XML_WRITE.g_table ;
g_elmt_tag_tbl       BEN_EXT_XML_WRITE.g_table ;
g_low_lvl_tbl        BEN_EXT_XML_WRITE.g_table ;
g_iana_char_set      varchar2(500) ;
g_prev_grop_val      ben_ext_rslt_dtl.group_val_01%type  ;
--
-----------------------------------------------------------------------------



function determine_sub_low_lvl (p_prev_lvl varchar2 ,
                                p_lvl      varchar2 ,
                                p_group    varchar2 default null ) return varchar2  is

l_ret_val varchar2(10)       := 'N' ;
l_proc    varchar2(72) := g_package||'determine_sub_low_lvl';
begin

 hr_Utility.set_location('Entering'||l_proc, 5);
 if p_prev_lvl  = 'P' and  p_lvl in ('CO','G','E','Y','R','F','ED','B','D','A','PR','T','TS','WG','WR')   then   --- person
    l_ret_val := 'Y' ;
 elsif p_prev_lvl in ( 'E') and  p_lvl in ('B','D','A','PR') then   -- Enrollment
     l_ret_val := 'Y' ;
 elsif p_prev_lvl in ( 'G') and  p_lvl in ('ED') then   -- eligible
     l_ret_val := 'Y' ;
 elsif p_prev_lvl in ( 'T') and  p_lvl in ('TS') then   -- timecard
     l_ret_val := 'Y' ;
 elsif p_prev_lvl  = 'OR' and  p_lvl in ( 'P','CO','G','E','Y','R','F','ED','B','D','A','PR','T','TS','WG','WR', 'PO')
       and  nvl(p_group,  '-1') <> '   ' and  nvl(p_group,'-1') =  nvl(g_prev_grop_val,'-1')
       then   --- organization subheader
      l_ret_val := 'Y' ;
 elsif p_prev_lvl  in('PO','JB','LO','PY') and  p_lvl in ('P','CO','G','E','Y','R','F','ED','B','D','A','PR','T','TS','WG','WR')
        and nvl(p_group ,  '-1') <> '   ' and  nvl(p_group,'-1') =  nvl(g_prev_grop_val,'-1')
         then   --- position/job/location/payroll subheader
      l_ret_val := 'Y' ;
 end if ;
 -- for first  level
 --if p_prev_lvl is null and p_lvl = 'P' then
 --   l_ret_val := 'Y' ;
 --elsif  (p_prev_lvl  is null and p_lvl = 'N' )  then
 --    l_ret_val := 'Y' ;
 --elsif p_prev_lvl  is null and p_lvl is not null  then
 if p_prev_lvl  is null and p_lvl is not null  then
     l_ret_val := 'Y' ;
 end if ;

 g_prev_grop_val := p_group ;

 hr_utility.set_location('p_prev_lvl  '||  p_prev_lvl  , 15);
 hr_utility.set_location('p_lvl  '||  p_lvl  , 15);
 hr_utility.set_location('Exiting '|| l_ret_val ||l_proc, 15);
 return l_ret_val ;

end determine_sub_low_lvl;


function get_low_lvl_name ( p_lvl      varchar2 ) return varchar2  is

l_ret_val varchar2(250)    ;
l_proc    varchar2(72) := g_package||' get_low_lvl_name';

cursor c is
select meaning
from hr_lookups
where lookup_type = 'BEN_EXT_LVL'
and   lookup_code =  p_lvl ;

begin

 hr_Utility.set_location('Entering'||l_proc, 5);
  open c ;
  fetch c into l_ret_val ;
  close c ;
  if  l_ret_val is not null then
      l_ret_val := translate(l_ret_val ,' !@#$%^&*()-+={}|[]\";:/.,<>?~`','_');
  end if ;

 hr_utility.set_location('Exiting '|| l_ret_val ||l_proc, 15);
 return  (l_ret_val ) ;

end get_low_lvl_name;


procedure  add_delete_sub_level(p_action      varchar2 ,
                                p_low_lvl_cd  varchar2)  is
l_proc    varchar2(72) := g_package||' add_delete_sub_level';

l_last number := g_low_lvl_tbl.last ;
begin
 hr_Utility.set_location('Entering'||l_proc, 5);
 hr_Utility.set_location(p_action ||' / '||p_low_lvl_cd , 5);


 hr_Utility.set_location('p_action'||p_action, 5);
 hr_Utility.set_location('l_last '||l_last, 5);

 if p_action = 'ADD'  then
      g_low_lvl_tbl(( nvl(l_last,0) + 1)) := p_low_lvl_cd ;
 end if ;

if p_action = 'DELETE' then

   for j in REVERSE 1   ..  l_last  Loop
      if  g_low_lvl_tbl(j) =  p_low_lvl_cd then
          hr_Utility.set_location('delete '||j, 5);
          g_low_lvl_tbl.delete(j) ;
          exit ;
      end if ;
   end loop ;

end if ;
hr_utility.set_location('Exiting ' ||l_proc, 15);

end  add_delete_sub_level ;




Function ext_xml_encode(p_text varchar2 ) return varchar2 is

l_text varchar2(4000) ;
begin
   l_text:= (replace(
             replace(
             replace(
             replace(p_text, '&'   , '&' || 'amp;' ),
                            '"',   '&'  || 'quot;'),
                            '<',   '&' ||'lt;'  ),
                            '>',  '&'  ||'gt;'  ));
   Return l_text ;

end ext_xml_encode ;



Procedure  Load_tags
          (p_tag_table in out nocopy BEN_EXT_XML_WRITE.g_table ,
           p_tag       in  varchar2
           ) is

l_proc     varchar2(72) := g_package||'Load_tags';
l_found    varchar2(1)  := 'N' ;
l_last     number       := nvl(p_tag_table.last,0) ;
begin

  --hr_Utility.set_location('Entering'||l_proc, 5);
 if p_tag_table.first is not null then
    for i in 1 .. l_last loop
      if  p_tag_table(i) = p_tag then
          l_found := 'Y' ;
          exit ;
      end if ;
     end loop ;
  end if ;
  if l_found = 'N' then
     p_tag_table(( nvl(l_last,0) + 1)) := p_tag ;
  end if ;


  --hr_utility.set_location('Exiting '||p_tag_table.last ||l_proc, 15);
End Load_tags;


Procedure write_style_sheet
          (p_drctry_name in varchar2,
           p_file_name in varchar2,
           p_ext_rslt_id in number,
           p_ext_dfn_tag in varchar2,
           p_ext_file_tag in varchar2) is

file_handle utl_file.file_type;
l_var  varchar2(4000) ;
l_proc     varchar2(72) := g_package||'write_style_sheet';
l_max_ext_line_size  Number := 32767 ;
l_output_name       ben_ext_rslt.output_name%type  ;

Begin
  --
  hr_Utility.set_location('Entering'||l_proc, 5);
  --l_output_name :=  'benxxssh.xsl' ;
   l_output_name := nvl(p_file_name, 'benxxssh') || '.xsl' ;
  --

  hr_Utility.set_location('out put '||l_output_name|| ' / '|| p_drctry_name, 5);
  file_handle := utl_file.fopen (p_drctry_name,l_output_name,'w' , l_max_ext_line_size );
  hr_Utility.set_location(' after header ', 5);
  --- Write the xml header
  utl_file.put_line(file_handle, '<?xml version="1.0" encoding="'||g_iana_char_set||'"?>');
  utl_file.put_line(file_handle, '<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">');
  utl_file.put_line(file_handle, '<xsl:template match="/">');
  utl_file.put_line(file_handle, '<html> <body>');

  hr_Utility.set_location(' after header ', 5);
  l_var := ' <xsl:for-each select="/'||'*'||'/'||p_ext_file_tag||'">
              <h2>
              <xsl:value-of select="@ext_dfn_name"/>
              </h2>
              <h5>
            Date : <xsl:value-of select="@effective_date"/>      Start Date :   <xsl:value-of select="@start_time"/>
               End Date : <xsl:value-of select="@end_time"/>
              </h5>
              <xsl:for-each select="' || 'oabext_person_record_set' ||'">
             <table border="1"> ' ;
       utl_file.put_line(file_handle, l_var);
      -- this is record level , there can be multiple rec with diff tag so relative path is used
      l_var := '
                  <xsl:for-each select="' || 'child::*' ||'">
                    <xsl:sort select="@ext_rec_person"/>
                   <!-- This diplay the record header for each recird -->
                 <tr> <th>
                 <xsl:value-of select="@ext_rec_name" />
                 </th> </tr>' ;
                 utl_file.put_line(file_handle, l_var);
                 l_var  := ' <xsl:for-each select="oabext_record_set">
                             <xsl:if test="@record_number=1"> ';
                  utl_file.put_line(file_handle, l_var);

                    for j in g_elmt_tag_tbl.first  .. g_elmt_tag_tbl.last loop
                        l_var  := '
                                 <xsl:for-each select="' || g_elmt_tag_tbl(j) ||'">
                              <th>  <xsl:value-of select="@ext_elmt_name"/> </th>
                              </xsl:for-each> ';
                         utl_file.put_line(file_handle, l_var);
                    end loop ;
                    l_var  := '
                    </xsl:if>
                 </xsl:for-each>
                 <!-- Listing Element Value   -->
                 <xsl:for-each select="oabext_record_set">
                 <tr>';

                  utl_file.put_line(file_handle, l_var);
                  for j in g_elmt_tag_tbl.first  .. g_elmt_tag_tbl.last loop
                         l_var  := '
                     <xsl:for-each select="'||g_elmt_tag_tbl(j)||'">
                         <td> <xsl:value-of select="."/> </td>
                     </xsl:for-each> ' ;
                       utl_file.put_line(file_handle, l_var);
                   end loop ;
                   l_var  := '
                 </tr>
                 </xsl:for-each>
            </xsl:for-each> ' ;
            utl_file.put_line(file_handle, l_var);
  l_var  :=  '</table>
       </xsl:for-each>
  </xsl:for-each> ' ;

  hr_Utility.set_location('out put '||l_var, 5);
  utl_file.put_line(file_handle,l_var );
  ---
  utl_file.put_line(file_handle, '</body> </html>');
  utl_file.put_line(file_handle, '</xsl:template>');
  utl_file.put_line(file_handle, '</xsl:stylesheet>');
  ---
  utl_file.fclose(file_handle);

  -- write to logfile the record count
  fnd_message.set_name('BEN','BEN_91878_EXT_TTL_RCRDS');
  fnd_file.put_line(fnd_file.log,fnd_message.get || ' ' || p_drctry_name||'/'||l_output_name ) ;
  hr_utility.set_location('Exiting'||l_proc, 15);

END write_style_sheet;



Procedure write_schema
          (p_drctry_name in varchar2,
           p_file_name in varchar2,
           p_ext_rslt_id in number,
           p_ext_dfn_tag in varchar2,
           p_ext_file_tag in varchar2) is

file_handle utl_file.file_type;
l_var         varchar2(4000) ;
l_proc     varchar2(72) := g_package||'write_schema';
l_max_ext_line_size  Number := 32767 ;
l_output_name       ben_ext_rslt.output_name%type  ;

Begin
  --
  hr_Utility.set_location('Entering'||l_proc, 5);

  l_output_name := nvl(p_file_name,'benxxsch' ) || '.xsd' ;
  --l_output_name := 'benxxsch.xsd' ;

  --
  file_handle := utl_file.fopen (p_drctry_name,l_output_name,'w' , l_max_ext_line_size );
  --- Write the xml header
  utl_file.put_line(file_handle, '<?xml version="1.0" encoding="'||g_iana_char_set||'"?>');
  utl_file.put_line(file_handle, '<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">');
--  utl_file.put_line(file_handle, '     targetNamespace="http://www.oracle.com/xml/OAB/ext"');
--  utl_file.put_line(file_handle, '     xmlns="http://www.oracle.com/xml/OAB/ext">');
  ----- Element Type
  for i in g_elmt_tag_tbl.first  .. g_elmt_tag_tbl.last loop
     l_var := '
    <xs:element name="'||g_elmt_tag_tbl(i)||'">
         <xs:complexType>
            <xs:simpleContent>
                <xs:extension base="xs:string">
                   <xs:attribute name="ext_elmt_name" type="xs:string" use="required"/>
                   <xs:attribute name="ext_elmt_seq" use="required"/>
                   <xs:attribute name="ext_elmt_type" type="xs:string" use="required"/>
                   <xs:attribute name="ext_elmt_length_" type="xs:string" />
                   <xs:attribute name="ext_elmt_format" type="xs:string" />
                   <xs:attribute name="ext_elmt_just" type="xs:string"/>
               </xs:extension>
           </xs:simpleContent>
        </xs:complexType>
    </xs:element> ' ;
    utl_file.put_line(file_handle,l_var );
  end loop ;

  ---- Creating for the record set
  l_var :='
    <xs:element name="oabext_record_set">
        <xs:complexType>
            <xs:choice maxOccurs="unbounded"> ' ;
               utl_file.put_line(file_handle,l_var );
               for i in g_elmt_tag_tbl.first  .. g_elmt_tag_tbl.last loop
                   l_var := '               <xs:element ref="'||g_elmt_tag_tbl(i)||'" minOccurs="0"/>' ;
                   utl_file.put_line(file_handle,l_var );
               end loop ;
            l_var :=  '
           </xs:choice>
           <xs:attribute name="record_number" type="xs:string" use="required"/>
        </xs:complexType>
    </xs:element>' ;
  utl_file.put_line(file_handle,l_var );


  ---  Creating for the records
  for i in  g_rcd_tag_tbl.first .. g_rcd_tag_tbl.last loop
    l_var := '
    <xs:element name="'||g_rcd_tag_tbl(i)||'">
        <xs:complexType>
            <xs:sequence>
                 <xs:element ref="oabext_record_set" maxOccurs="unbounded"/>
            </xs:sequence>
            <xs:attribute name="ext_rec_name" type="xs:string" use="required"/>
            <xs:attribute name="ext_rec_seq" type="xs:byte" use="required"/>
            <xs:attribute name="ext_rec_type" type="xs:string" use="required"/>
            <xs:attribute name="ext_rec_person" type="xs:string"/>
        </xs:complexType>
    </xs:element> ' ;
    utl_file.put_line(file_handle,l_var );
  end loop ;


--- File type
  l_var := '
    <xs:element name="'||'oabext_person_record_set'||'">
       <xs:complexType>
           <xs:choice  maxOccurs="unbounded"> ';
           utl_file.put_line(file_handle,l_var );
           for i in  g_rcd_tag_tbl.first .. g_rcd_tag_tbl.last loop
               l_var := '               <xs:element ref="'||g_rcd_tag_tbl(i)||'"/> ' ;
               utl_file.put_line(file_handle,l_var );
           end loop;
           l_var := '
           </xs:choice>
           <xs:attribute name="person_name" type="xs:string"/>
           <xs:attribute name="employee_number" type="xs:string"/>
       </xs:complexType>
    </xs:element> ' ;

  utl_file.put_line(file_handle, l_var);






  --- File type
  l_var := '
    <xs:element name="'||p_ext_file_tag||'">
       <xs:complexType>
           <xs:choice  maxOccurs="unbounded"> ';
           utl_file.put_line(file_handle,l_var );
           l_var := '     <xs:element ref="'||'oabext_person_record_set'||'"/> ' ;
           utl_file.put_line(file_handle,l_var );
           l_var := '
           </xs:choice>
           <xs:attribute name="ext_dfn_name" type="xs:string" use="required"/>
           <xs:attribute name="ext_type" type="xs:string" use="required"/>
           <xs:attribute name="effective_date" type="xs:string" use="required"/>
           <xs:attribute name="start_time" type="xs:string" use="required"/>
           <xs:attribute name="end_time" type="xs:string" use="required"/>
       </xs:complexType>
    </xs:element> ' ;

  utl_file.put_line(file_handle, l_var);
     l_var := '
     <xs:element name="'||p_ext_dfn_tag||'">
                <xs:complexType>
                        <xs:sequence>
                                <xs:element ref="'||p_ext_file_tag||'"/>
                        </xs:sequence>
                </xs:complexType>
     </xs:element>
  </xs:schema>' ;

  --- Closing Root
  utl_file.put_line(file_handle,l_var );
  --- Closing the file
  utl_file.fclose(file_handle);

  -- write to logfile the record count
   fnd_message.set_name('BEN','BEN_91878_EXT_TTL_RCRDS');
   fnd_file.put_line(fnd_file.log,fnd_message.get || ' ' || p_drctry_name||'/'||l_output_name ) ;
hr_utility.set_location('Exiting'||l_proc, 15);




END write_schema;





Procedure write_xdo_pdf
          (p_drctry_name      in varchar2,
           p_pdf_output_name  in varchar2,
           p_input_name       in varchar2,
           p_template_id      in number,
           p_output_type      in varchar2
           ) is

  l_proc     varchar2(72) := g_package||'write_xdo_pdf';


  l_pdf_output_name  ben_ext_rslt.output_name%type ;
  l_input_name      ben_ext_rslt.output_name%type ;
  l_extn_name        varchar2(50) ;
  l_template_cd      xdo_templates_b.template_code%type  ;
  l_application_id   number ;
  l_APPLICATION_SHORT_NAME   xdo_templates_b.APPLICATION_SHORT_NAME%type ;
  l_request_id            number ;


  cursor c_xdo (p_template_id number) is
  select  template_code ,
          application_id,
          APPLICATION_SHORT_NAME
  from xdo_templates_b xdo
  where template_id = p_template_id ;

Begin
  --
  hr_Utility.set_location('Entering'||l_proc, 5);



  open c_xdo(p_template_id)  ;
  fetch c_xdo into l_template_cd,
                   l_application_id,
                   l_APPLICATION_SHORT_NAME   ;
  close  c_xdo ;

  if l_template_cd is not null  then
     if substr(p_drctry_name, -1) = '/' then
        l_input_name     :=   p_drctry_name || p_input_name  ;
        l_pdf_output_name :=  p_drctry_name || p_pdf_output_name ;
     else
        --- check it is window kind of path or unix
        if instr(p_drctry_name , '\') > 0 then
           l_input_name       := p_drctry_name ||'\'||p_input_name ;
           l_pdf_output_name  := p_drctry_name ||'\'||p_pdf_output_name ;
        else
           l_input_name       := p_drctry_name ||'/'||p_input_name ;
           l_pdf_output_name  := p_drctry_name ||'/'||p_pdf_output_name ;
         end if ;
     end if  ;


     -- call  concurrent manager to execute the pdf
     l_request_id := fnd_request.submit_request
                    (application => 'BEN'
                     ,program     => 'BENXDXML'
                     ,description => NULL
                     ,sub_request => FALSE
                     ,argument1   => l_application_id
                     ,argument2   => l_template_cd
                     ,argument3   => l_input_name
                     ,argument4   => l_pdf_output_name
                     ,argument5   => p_output_type
                     );

  end if ;

  hr_utility.set_location('Exiting'||l_proc, 15);

END write_xdo_pdf;







procedure load_arrays
    (p_ext_rcd_id in number,
     p_val_01 in varchar2,
     p_val_02 in varchar2,
     p_val_03 in varchar2,
     p_val_04 in varchar2,
     p_val_05 in varchar2,
     p_val_06 in varchar2,
     p_val_07 in varchar2,
     p_val_08 in varchar2,
     p_val_09 in varchar2,
     p_val_10 in varchar2,
     p_val_11 in varchar2,
     p_val_12 in varchar2,
     p_val_13 in varchar2,
     p_val_14 in varchar2,
     p_val_15 in varchar2,
     p_val_16 in varchar2,
     p_val_17 in varchar2,
     p_val_18 in varchar2,
     p_val_19 in varchar2,
     p_val_20 in varchar2,
     p_val_21 in varchar2,
     p_val_22 in varchar2,
     p_val_23 in varchar2,
     p_val_24 in varchar2,
     p_val_25 in varchar2,
     p_val_26 in varchar2,
     p_val_27 in varchar2,
     p_val_28 in varchar2,
     p_val_29 in varchar2,
     p_val_30 in varchar2,
     p_val_31 in varchar2,
     p_val_32 in varchar2,
     p_val_33 in varchar2,
     p_val_34 in varchar2,
     p_val_35 in varchar2,
     p_val_36 in varchar2,
     p_val_37 in varchar2,
     p_val_38 in varchar2,
     p_val_39 in varchar2,
     p_val_40 in varchar2,
     p_val_41 in varchar2,
     p_val_42 in varchar2,
     p_val_43 in varchar2,
     p_val_44 in varchar2,
     p_val_45 in varchar2,
     p_val_46 in varchar2,
     p_val_47 in varchar2,
     p_val_48 in varchar2,
     p_val_49 in varchar2,
     p_val_50 in varchar2,
     p_val_51 in varchar2,
     p_val_52 in varchar2,
     p_val_53 in varchar2,
     p_val_54 in varchar2,
     p_val_55 in varchar2,
     p_val_56 in varchar2,
     p_val_57 in varchar2,
     p_val_58 in varchar2,
     p_val_59 in varchar2,
     p_val_60 in varchar2,
     p_val_61 in varchar2,
     p_val_62 in varchar2,
     p_val_63 in varchar2,
     p_val_64 in varchar2,
     p_val_65 in varchar2,
     p_val_66 in varchar2,
     p_val_67 in varchar2,
     p_val_68 in varchar2,
     p_val_69 in varchar2,
     p_val_70 in varchar2,
     p_val_71 in varchar2,
     p_val_72 in varchar2,
     p_val_73 in varchar2,
     p_val_74 in varchar2,
     p_val_75 in varchar2,
     p_val_76 in varchar2,
     p_val_77 in varchar2,
     p_val_78 in varchar2,
     p_val_79 in varchar2,
     p_val_80 in varchar2,
     p_val_81 in varchar2,
     p_val_82 in varchar2,
     p_val_83 in varchar2,
     p_val_84 in varchar2,
     p_val_85 in varchar2,
     p_val_86 in varchar2,
     p_val_87 in varchar2,
     p_val_88 in varchar2,
     p_val_89 in varchar2,
     p_val_90 in varchar2,
     p_val_91 in varchar2,
     p_val_92 in varchar2,
     p_val_93 in varchar2,
     p_val_94 in varchar2,
     p_val_95 in varchar2,
     p_val_96 in varchar2,
     p_val_97 in varchar2,
     p_val_98 in varchar2,
     p_val_99 in varchar2,
     p_val_100 in varchar2,
     p_val_101 in varchar2,
     p_val_102 in varchar2,
     p_val_103 in varchar2,
     p_val_104 in varchar2,
     p_val_105 in varchar2,
     p_val_106 in varchar2,
     p_val_107 in varchar2,
     p_val_108 in varchar2,
     p_val_109 in varchar2,
     p_val_110 in varchar2,
     p_val_111 in varchar2,
     p_val_112 in varchar2,
     p_val_113 in varchar2,
     p_val_114 in varchar2,
     p_val_115 in varchar2,
     p_val_116 in varchar2,
     p_val_117 in varchar2,
     p_val_118 in varchar2,
     p_val_119 in varchar2,
     p_val_120 in varchar2,
     p_val_121 in varchar2,
     p_val_122 in varchar2,
     p_val_123 in varchar2,
     p_val_124 in varchar2,
     p_val_125 in varchar2,
     p_val_126 in varchar2,
     p_val_127 in varchar2,
     p_val_128 in varchar2,
     p_val_129 in varchar2,
     p_val_130 in varchar2,
     p_val_131 in varchar2,
     p_val_132 in varchar2,
     p_val_133 in varchar2,
     p_val_134 in varchar2,
     p_val_135 in varchar2,
     p_val_136 in varchar2,
     p_val_137 in varchar2,
     p_val_138 in varchar2,
     p_val_139 in varchar2,
     p_val_140 in varchar2,
     p_val_141 in varchar2,
     p_val_142 in varchar2,
     p_val_143 in varchar2,
     p_val_144 in varchar2,
     p_val_145 in varchar2,
     p_val_146 in varchar2,
     p_val_147 in varchar2,
     p_val_148 in varchar2,
     p_val_149 in varchar2,
     p_val_150 in varchar2,
     p_val_151 in varchar2,
     p_val_152 in varchar2,
     p_val_153 in varchar2,
     p_val_154 in varchar2,
     p_val_155 in varchar2,
     p_val_156 in varchar2,
     p_val_157 in varchar2,
     p_val_158 in varchar2,
     p_val_159 in varchar2,
     p_val_160 in varchar2,
     p_val_161 in varchar2,
     p_val_162 in varchar2,
     p_val_163 in varchar2,
     p_val_164 in varchar2,
     p_val_165 in varchar2,
     p_val_166 in varchar2,
     p_val_167 in varchar2,
     p_val_168 in varchar2,
     p_val_169 in varchar2,
     p_val_170 in varchar2,
     p_val_171 in varchar2,
     p_val_172 in varchar2,
     p_val_173 in varchar2,
     p_val_174 in varchar2,
     p_val_175 in varchar2,
     p_val_176 in varchar2,
     p_val_177 in varchar2,
     p_val_178 in varchar2,
     p_val_179 in varchar2,
     p_val_180 in varchar2,
     p_val_181 in varchar2,
     p_val_182 in varchar2,
     p_val_183 in varchar2,
     p_val_184 in varchar2,
     p_val_185 in varchar2,
     p_val_186 in varchar2,
     p_val_187 in varchar2,
     p_val_188 in varchar2,
     p_val_189 in varchar2,
     p_val_190 in varchar2,
     p_val_191 in varchar2,
     p_val_192 in varchar2,
     p_val_193 in varchar2,
     p_val_194 in varchar2,
     p_val_195 in varchar2,
     p_val_196 in varchar2,
     p_val_197 in varchar2,
     p_val_198 in varchar2,
     p_val_199 in varchar2,
     p_val_200 in varchar2,
     p_val_201 in varchar2,
     p_val_202 in varchar2,
     p_val_203 in varchar2,
     p_val_204 in varchar2,
     p_val_205 in varchar2,
     p_val_206 in varchar2,
     p_val_207 in varchar2,
     p_val_208 in varchar2,
     p_val_209 in varchar2,
     p_val_210 in varchar2,
     p_val_211 in varchar2,
     p_val_212 in varchar2,
     p_val_213 in varchar2,
     p_val_214 in varchar2,
     p_val_215 in varchar2,
     p_val_216 in varchar2,
     p_val_217 in varchar2,
     p_val_218 in varchar2,
     p_val_219 in varchar2,
     p_val_220 in varchar2,
     p_val_221 in varchar2,
     p_val_222 in varchar2,
     p_val_223 in varchar2,
     p_val_224 in varchar2,
     p_val_225 in varchar2,
     p_val_226 in varchar2,
     p_val_227 in varchar2,
     p_val_228 in varchar2,
     p_val_229 in varchar2,
     p_val_230 in varchar2,
     p_val_231 in varchar2,
     p_val_232 in varchar2,
     p_val_233 in varchar2,
     p_val_234 in varchar2,
     p_val_235 in varchar2,
     p_val_236 in varchar2,
     p_val_237 in varchar2,
     p_val_238 in varchar2,
     p_val_239 in varchar2,
     p_val_240 in varchar2,
     p_val_241 in varchar2,
     p_val_242 in varchar2,
     p_val_243 in varchar2,
     p_val_244 in varchar2,
     p_val_245 in varchar2,
     p_val_246 in varchar2,
     p_val_247 in varchar2,
     p_val_248 in varchar2,
     p_val_249 in varchar2,
     p_val_250 in varchar2,
     p_val_251 in varchar2,
     p_val_252 in varchar2,
     p_val_253 in varchar2,
     p_val_254 in varchar2,
     p_val_255 in varchar2,
     p_val_256 in varchar2,
     p_val_257 in varchar2,
     p_val_258 in varchar2,
     p_val_259 in varchar2,
     p_val_260 in varchar2,
     p_val_261 in varchar2,
     p_val_262 in varchar2,
     p_val_263 in varchar2,
     p_val_264 in varchar2,
     p_val_265 in varchar2,
     p_val_266 in varchar2,
     p_val_267 in varchar2,
     p_val_268 in varchar2,
     p_val_269 in varchar2,
     p_val_270 in varchar2,
     p_val_271 in varchar2,
     p_val_272 in varchar2,
     p_val_273 in varchar2,
     p_val_274 in varchar2,
     p_val_275 in varchar2,
     p_val_276 in varchar2,
     p_val_277 in varchar2,
     p_val_278 in varchar2,
     p_val_279 in varchar2,
     p_val_280 in varchar2,
     p_val_281 in varchar2,
     p_val_282 in varchar2,
     p_val_283 in varchar2,
     p_val_284 in varchar2,
     p_val_285 in varchar2,
     p_val_286 in varchar2,
     p_val_287 in varchar2,
     p_val_288 in varchar2,
     p_val_289 in varchar2,
     p_val_290 in varchar2,
     p_val_291 in varchar2,
     p_val_292 in varchar2,
     p_val_293 in varchar2,
     p_val_294 in varchar2,
     p_val_295 in varchar2,
     p_val_296 in varchar2,
     p_val_297 in varchar2,
     p_val_298 in varchar2,
     p_val_299 in varchar2,
     p_val_300 in varchar2,
     p_seq_num in number) is
--
  l_proc     varchar2(72) := g_package||'load_arrays';
--
begin
--
  hr_utility.set_location('Entering'||l_proc, 5);
--
 ben_ext_write.g_val(01) :=  ext_xml_encode( p_val_01) ;
 ben_ext_write.g_val(02) :=  ext_xml_encode( p_val_02) ;
 ben_ext_write.g_val(03) :=  ext_xml_encode( p_val_03) ;
 ben_ext_write.g_val(04) :=  ext_xml_encode( p_val_04) ;
 ben_ext_write.g_val(05) :=  ext_xml_encode( p_val_05) ;
 ben_ext_write.g_val(06) :=  ext_xml_encode( p_val_06) ;
 ben_ext_write.g_val(07) :=  ext_xml_encode( p_val_07) ;
 ben_ext_write.g_val(08) :=  ext_xml_encode( p_val_08) ;
 ben_ext_write.g_val(09) :=  ext_xml_encode( p_val_09) ;
 ben_ext_write.g_val(10) :=  ext_xml_encode( p_val_10) ;
 ben_ext_write.g_val(11) :=  ext_xml_encode( p_val_11) ;
 ben_ext_write.g_val(12) :=  ext_xml_encode( p_val_12) ;
 ben_ext_write.g_val(13) :=  ext_xml_encode( p_val_13) ;
 ben_ext_write.g_val(14) :=  ext_xml_encode( p_val_14) ;
 ben_ext_write.g_val(15) :=  ext_xml_encode( p_val_15) ;
 ben_ext_write.g_val(16) :=  ext_xml_encode( p_val_16) ;
 ben_ext_write.g_val(17) :=  ext_xml_encode( p_val_17) ;
 ben_ext_write.g_val(18) :=  ext_xml_encode( p_val_18) ;
 ben_ext_write.g_val(19) :=  ext_xml_encode( p_val_19) ;
 ben_ext_write.g_val(20) :=  ext_xml_encode( p_val_20) ;
 ben_ext_write.g_val(21) :=  ext_xml_encode( p_val_21) ;
 ben_ext_write.g_val(22) :=  ext_xml_encode( p_val_22) ;
 ben_ext_write.g_val(23) :=  ext_xml_encode( p_val_23) ;
 ben_ext_write.g_val(24) :=  ext_xml_encode( p_val_24) ;
 ben_ext_write.g_val(25) :=  ext_xml_encode( p_val_25) ;
 ben_ext_write.g_val(26) :=  ext_xml_encode( p_val_26) ;
 ben_ext_write.g_val(27) :=  ext_xml_encode( p_val_27) ;
 ben_ext_write.g_val(28) :=  ext_xml_encode( p_val_28) ;
 ben_ext_write.g_val(29) :=  ext_xml_encode( p_val_29) ;
 ben_ext_write.g_val(30) :=  ext_xml_encode( p_val_30) ;
 ben_ext_write.g_val(31) :=  ext_xml_encode( p_val_31) ;
 ben_ext_write.g_val(32) :=  ext_xml_encode( p_val_32) ;
 ben_ext_write.g_val(33) :=  ext_xml_encode( p_val_33) ;
 ben_ext_write.g_val(34) :=  ext_xml_encode( p_val_34) ;
 ben_ext_write.g_val(35) :=  ext_xml_encode( p_val_35) ;
 ben_ext_write.g_val(36) :=  ext_xml_encode( p_val_36) ;
 ben_ext_write.g_val(37) :=  ext_xml_encode( p_val_37) ;
 ben_ext_write.g_val(38) :=  ext_xml_encode( p_val_38) ;
 ben_ext_write.g_val(39) :=  ext_xml_encode( p_val_39) ;
 ben_ext_write.g_val(40) :=  ext_xml_encode( p_val_40) ;
 ben_ext_write.g_val(41) :=  ext_xml_encode( p_val_41) ;
 ben_ext_write.g_val(42) :=  ext_xml_encode( p_val_42) ;
 ben_ext_write.g_val(43) :=  ext_xml_encode( p_val_43) ;
 ben_ext_write.g_val(44) :=  ext_xml_encode( p_val_44) ;
 ben_ext_write.g_val(45) :=  ext_xml_encode( p_val_45) ;
 ben_ext_write.g_val(46) :=  ext_xml_encode( p_val_46) ;
 ben_ext_write.g_val(47) :=  ext_xml_encode( p_val_47) ;
 ben_ext_write.g_val(48) :=  ext_xml_encode( p_val_48) ;
 ben_ext_write.g_val(49) :=  ext_xml_encode( p_val_49) ;
 ben_ext_write.g_val(50) :=  ext_xml_encode( p_val_50) ;
 ben_ext_write.g_val(51) :=  ext_xml_encode( p_val_51) ;
 ben_ext_write.g_val(52) :=  ext_xml_encode( p_val_52) ;
 ben_ext_write.g_val(53) :=  ext_xml_encode( p_val_53) ;
 ben_ext_write.g_val(54) :=  ext_xml_encode( p_val_54) ;
 ben_ext_write.g_val(55) :=  ext_xml_encode( p_val_55) ;
 ben_ext_write.g_val(56) :=  ext_xml_encode( p_val_56) ;
 ben_ext_write.g_val(57) :=  ext_xml_encode( p_val_57) ;
 ben_ext_write.g_val(58) :=  ext_xml_encode( p_val_58) ;
 ben_ext_write.g_val(59) :=  ext_xml_encode( p_val_59) ;
 ben_ext_write.g_val(60) :=  ext_xml_encode( p_val_60) ;
 ben_ext_write.g_val(61) :=  ext_xml_encode( p_val_61) ;
 ben_ext_write.g_val(62) :=  ext_xml_encode( p_val_62) ;
 ben_ext_write.g_val(63) :=  ext_xml_encode( p_val_63) ;
 ben_ext_write.g_val(64) :=  ext_xml_encode( p_val_64) ;
 ben_ext_write.g_val(65) :=  ext_xml_encode( p_val_65) ;
 ben_ext_write.g_val(66) :=  ext_xml_encode( p_val_66) ;
 ben_ext_write.g_val(67) :=  ext_xml_encode( p_val_67) ;
 ben_ext_write.g_val(68) :=  ext_xml_encode( p_val_68) ;
 ben_ext_write.g_val(69) :=  ext_xml_encode( p_val_69) ;
 ben_ext_write.g_val(70) :=  ext_xml_encode( p_val_70) ;
 ben_ext_write.g_val(71) :=  ext_xml_encode( p_val_71) ;
 ben_ext_write.g_val(72) :=  ext_xml_encode( p_val_72) ;
 ben_ext_write.g_val(73) :=  ext_xml_encode( p_val_73) ;
 ben_ext_write.g_val(74) :=  ext_xml_encode( p_val_74) ;
 ben_ext_write.g_val(75) :=  ext_xml_encode( p_val_75) ;
 ben_ext_write.g_val(76) := ext_xml_encode( p_val_76 );
 ben_ext_write.g_val(77) := ext_xml_encode( p_val_77 );
 ben_ext_write.g_val(78) := ext_xml_encode( p_val_78 );
 ben_ext_write.g_val(79) := ext_xml_encode( p_val_79 );
 ben_ext_write.g_val(80) := ext_xml_encode( p_val_80 );
 ben_ext_write.g_val(81) := ext_xml_encode( p_val_81 );
 ben_ext_write.g_val(82) := ext_xml_encode( p_val_82 );
 ben_ext_write.g_val(83) := ext_xml_encode( p_val_83 );
 ben_ext_write.g_val(84) := ext_xml_encode( p_val_84 );
 ben_ext_write.g_val(85) := ext_xml_encode( p_val_85 );
 ben_ext_write.g_val(86) := ext_xml_encode( p_val_86 );
 ben_ext_write.g_val(87) := ext_xml_encode( p_val_87 );
 ben_ext_write.g_val(88) := ext_xml_encode( p_val_88 );
 ben_ext_write.g_val(89) := ext_xml_encode( p_val_89 );
 ben_ext_write.g_val(90) := ext_xml_encode( p_val_90 );
 ben_ext_write.g_val(91) := ext_xml_encode( p_val_91 );
 ben_ext_write.g_val(92) := ext_xml_encode( p_val_92 );
 ben_ext_write.g_val(93) := ext_xml_encode( p_val_93 );
 ben_ext_write.g_val(94) := ext_xml_encode( p_val_94 );
 ben_ext_write.g_val(95) := ext_xml_encode( p_val_95 );
 ben_ext_write.g_val(96) := ext_xml_encode( p_val_96 );
 ben_ext_write.g_val(97) := ext_xml_encode( p_val_97 );
 ben_ext_write.g_val(98) := ext_xml_encode( p_val_98 );
 ben_ext_write.g_val(99) := ext_xml_encode( p_val_99 );
 ben_ext_write.g_val(100) := ext_xml_encode( p_val_100 );
 ben_ext_write.g_val(101) := ext_xml_encode( p_val_101 );
 ben_ext_write.g_val(102) := ext_xml_encode( p_val_102 );
 ben_ext_write.g_val(103) := ext_xml_encode( p_val_103 );
 ben_ext_write.g_val(104) := ext_xml_encode( p_val_104 );
 ben_ext_write.g_val(105) := ext_xml_encode( p_val_105 );
 ben_ext_write.g_val(106) := ext_xml_encode( p_val_106 );
 ben_ext_write.g_val(107) := ext_xml_encode( p_val_107 );
 ben_ext_write.g_val(108) := ext_xml_encode( p_val_108 );
 ben_ext_write.g_val(109) := ext_xml_encode( p_val_109 );
 ben_ext_write.g_val(110) := ext_xml_encode( p_val_110 );
 ben_ext_write.g_val(111) := ext_xml_encode( p_val_111 );
 ben_ext_write.g_val(112) := ext_xml_encode( p_val_112 );
 ben_ext_write.g_val(113) := ext_xml_encode( p_val_113 );
 ben_ext_write.g_val(114) := ext_xml_encode( p_val_114 );
 ben_ext_write.g_val(115) := ext_xml_encode( p_val_115 );
 ben_ext_write.g_val(116) := ext_xml_encode( p_val_116 );
 ben_ext_write.g_val(117) := ext_xml_encode( p_val_117 );
 ben_ext_write.g_val(118) := ext_xml_encode( p_val_118 );
 ben_ext_write.g_val(119) := ext_xml_encode( p_val_119 );
 ben_ext_write.g_val(120) := ext_xml_encode( p_val_120 );
 ben_ext_write.g_val(121) := ext_xml_encode( p_val_121 );
 ben_ext_write.g_val(122) := ext_xml_encode( p_val_122 );
 ben_ext_write.g_val(123) := ext_xml_encode( p_val_123 );
 ben_ext_write.g_val(124) := ext_xml_encode( p_val_124 );
 ben_ext_write.g_val(125) := ext_xml_encode( p_val_125 );
 ben_ext_write.g_val(126) := ext_xml_encode( p_val_126 );
 ben_ext_write.g_val(127) := ext_xml_encode( p_val_127 );
 ben_ext_write.g_val(128) := ext_xml_encode( p_val_128 );
 ben_ext_write.g_val(129) := ext_xml_encode( p_val_129 );
 ben_ext_write.g_val(130) := ext_xml_encode( p_val_130 );
 ben_ext_write.g_val(131) := ext_xml_encode( p_val_131 );
 ben_ext_write.g_val(132) := ext_xml_encode( p_val_132 );
 ben_ext_write.g_val(133) := ext_xml_encode( p_val_133 );
 ben_ext_write.g_val(134) := ext_xml_encode( p_val_134 );
 ben_ext_write.g_val(135) := ext_xml_encode( p_val_135 );
 ben_ext_write.g_val(136) := ext_xml_encode( p_val_136 );
 ben_ext_write.g_val(137) := ext_xml_encode( p_val_137 );
 ben_ext_write.g_val(138) := ext_xml_encode( p_val_138 );
 ben_ext_write.g_val(139) := ext_xml_encode( p_val_139 );
 ben_ext_write.g_val(140) := ext_xml_encode( p_val_140 );
 ben_ext_write.g_val(141) := ext_xml_encode( p_val_141 );
 ben_ext_write.g_val(142) := ext_xml_encode( p_val_142 );
 ben_ext_write.g_val(143) := ext_xml_encode( p_val_143 );
 ben_ext_write.g_val(144) := ext_xml_encode( p_val_144 );
 ben_ext_write.g_val(145) := ext_xml_encode( p_val_145 );
 ben_ext_write.g_val(146) := ext_xml_encode( p_val_146 );
 ben_ext_write.g_val(147) := ext_xml_encode( p_val_147 );
 ben_ext_write.g_val(148) := ext_xml_encode( p_val_148 );
 ben_ext_write.g_val(149) := ext_xml_encode( p_val_149 );
 ben_ext_write.g_val(150) := ext_xml_encode( p_val_150 );
 ben_ext_write.g_val(151) := ext_xml_encode( p_val_151 );
 ben_ext_write.g_val(152) := ext_xml_encode( p_val_152 );
 ben_ext_write.g_val(153) := ext_xml_encode( p_val_153 );
 ben_ext_write.g_val(154) := ext_xml_encode( p_val_154 );
 ben_ext_write.g_val(155) := ext_xml_encode( p_val_155 );
 ben_ext_write.g_val(156) := ext_xml_encode( p_val_156 );
 ben_ext_write.g_val(157) := ext_xml_encode( p_val_157 );
 ben_ext_write.g_val(158) := ext_xml_encode( p_val_158 );
 ben_ext_write.g_val(159) := ext_xml_encode( p_val_159 );
 ben_ext_write.g_val(160) := ext_xml_encode( p_val_160 );
 ben_ext_write.g_val(161) := ext_xml_encode( p_val_161 );
 ben_ext_write.g_val(162) := ext_xml_encode( p_val_162 );
 ben_ext_write.g_val(163) := ext_xml_encode( p_val_163 );
 ben_ext_write.g_val(164) := ext_xml_encode( p_val_164 );
 ben_ext_write.g_val(165) := ext_xml_encode( p_val_165 );
 ben_ext_write.g_val(166) := ext_xml_encode( p_val_166 );
 ben_ext_write.g_val(167) := ext_xml_encode( p_val_167 );
 ben_ext_write.g_val(168) := ext_xml_encode( p_val_168 );
 ben_ext_write.g_val(169) := ext_xml_encode( p_val_169 );
 ben_ext_write.g_val(170) := ext_xml_encode( p_val_170 );
 ben_ext_write.g_val(171) := ext_xml_encode( p_val_171 );
 ben_ext_write.g_val(172) := ext_xml_encode( p_val_172 );
 ben_ext_write.g_val(173) := ext_xml_encode( p_val_173 );
 ben_ext_write.g_val(174) := ext_xml_encode( p_val_174 );
 ben_ext_write.g_val(175) := ext_xml_encode( p_val_175 );
 ben_ext_write.g_val(176) := ext_xml_encode( p_val_176 );
 ben_ext_write.g_val(177) := ext_xml_encode( p_val_177 );
 ben_ext_write.g_val(178) := ext_xml_encode( p_val_178 );
 ben_ext_write.g_val(179) := ext_xml_encode( p_val_179 );
 ben_ext_write.g_val(180) := ext_xml_encode( p_val_180 );
 ben_ext_write.g_val(181) := ext_xml_encode( p_val_181 );
 ben_ext_write.g_val(182) := ext_xml_encode( p_val_182 );
 ben_ext_write.g_val(183) := ext_xml_encode( p_val_183 );
 ben_ext_write.g_val(184) := ext_xml_encode( p_val_184 );
 ben_ext_write.g_val(185) := ext_xml_encode( p_val_185 );
 ben_ext_write.g_val(186) := ext_xml_encode( p_val_186 );
 ben_ext_write.g_val(187) := ext_xml_encode( p_val_187 );
 ben_ext_write.g_val(188) := ext_xml_encode( p_val_188 );
 ben_ext_write.g_val(189) := ext_xml_encode( p_val_189 );
 ben_ext_write.g_val(190) := ext_xml_encode( p_val_190 );
 ben_ext_write.g_val(191) := ext_xml_encode( p_val_191 );
 ben_ext_write.g_val(192) := ext_xml_encode( p_val_192 );
 ben_ext_write.g_val(193) := ext_xml_encode( p_val_193 );
 ben_ext_write.g_val(194) := ext_xml_encode( p_val_194 );
 ben_ext_write.g_val(195) := ext_xml_encode( p_val_195 );
 ben_ext_write.g_val(196) := ext_xml_encode( p_val_196 );
 ben_ext_write.g_val(197) := ext_xml_encode( p_val_197 );
 ben_ext_write.g_val(198) := ext_xml_encode( p_val_198 );
 ben_ext_write.g_val(199) := ext_xml_encode( p_val_199 );
 ben_ext_write.g_val(200) := ext_xml_encode( p_val_200 );
 ben_ext_write.g_val(201) := ext_xml_encode( p_val_201 );
 ben_ext_write.g_val(202) := ext_xml_encode( p_val_202 );
 ben_ext_write.g_val(203) := ext_xml_encode( p_val_203 );
 ben_ext_write.g_val(204) := ext_xml_encode( p_val_204 );
 ben_ext_write.g_val(205) := ext_xml_encode( p_val_205 );
 ben_ext_write.g_val(206) := ext_xml_encode( p_val_206 );
 ben_ext_write.g_val(207) := ext_xml_encode( p_val_207 );
 ben_ext_write.g_val(208) := ext_xml_encode( p_val_208 );
 ben_ext_write.g_val(209) := ext_xml_encode( p_val_209 );
 ben_ext_write.g_val(210) := ext_xml_encode( p_val_210 );
 ben_ext_write.g_val(211) := ext_xml_encode( p_val_211 );
 ben_ext_write.g_val(212) := ext_xml_encode( p_val_212 );
 ben_ext_write.g_val(213) := ext_xml_encode( p_val_213 );
 ben_ext_write.g_val(214) := ext_xml_encode( p_val_214 );
 ben_ext_write.g_val(215) := ext_xml_encode( p_val_215 );
 ben_ext_write.g_val(216) := ext_xml_encode( p_val_216 );
 ben_ext_write.g_val(217) := ext_xml_encode( p_val_217 );
 ben_ext_write.g_val(218) := ext_xml_encode( p_val_218 );
 ben_ext_write.g_val(219) := ext_xml_encode( p_val_219 );
 ben_ext_write.g_val(220) := ext_xml_encode( p_val_220 );
 ben_ext_write.g_val(221) := ext_xml_encode( p_val_221 );
 ben_ext_write.g_val(222) := ext_xml_encode( p_val_222 );
 ben_ext_write.g_val(223) := ext_xml_encode( p_val_223 );
 ben_ext_write.g_val(224) := ext_xml_encode( p_val_224 );
 ben_ext_write.g_val(225) := ext_xml_encode( p_val_225 );
 ben_ext_write.g_val(226) := ext_xml_encode( p_val_226 );
 ben_ext_write.g_val(227) := ext_xml_encode( p_val_227 );
 ben_ext_write.g_val(228) := ext_xml_encode( p_val_228 );
 ben_ext_write.g_val(229) := ext_xml_encode( p_val_229 );
 ben_ext_write.g_val(230) := ext_xml_encode( p_val_230 );
 ben_ext_write.g_val(231) := ext_xml_encode( p_val_231 );
 ben_ext_write.g_val(232) := ext_xml_encode( p_val_232 );
 ben_ext_write.g_val(233) := ext_xml_encode( p_val_233 );
 ben_ext_write.g_val(234) := ext_xml_encode( p_val_234 );
 ben_ext_write.g_val(235) := ext_xml_encode( p_val_235 );
 ben_ext_write.g_val(236) := ext_xml_encode( p_val_236 );
 ben_ext_write.g_val(237) := ext_xml_encode( p_val_237 );
 ben_ext_write.g_val(238) := ext_xml_encode( p_val_238 );
 ben_ext_write.g_val(239) := ext_xml_encode( p_val_239 );
 ben_ext_write.g_val(240) := ext_xml_encode( p_val_240 );
 ben_ext_write.g_val(241) := ext_xml_encode( p_val_241 );
 ben_ext_write.g_val(242) := ext_xml_encode( p_val_242 );
 ben_ext_write.g_val(243) := ext_xml_encode( p_val_243 );
 ben_ext_write.g_val(244) := ext_xml_encode( p_val_244 );
 ben_ext_write.g_val(245) := ext_xml_encode( p_val_245 );
 ben_ext_write.g_val(246) := ext_xml_encode( p_val_246 );
 ben_ext_write.g_val(247) := ext_xml_encode( p_val_247 );
 ben_ext_write.g_val(248) := ext_xml_encode( p_val_248 );
 ben_ext_write.g_val(249) := ext_xml_encode( p_val_249 );
 ben_ext_write.g_val(250) := ext_xml_encode( p_val_250 );
 ben_ext_write.g_val(251) := ext_xml_encode( p_val_251 );
 ben_ext_write.g_val(252) := ext_xml_encode( p_val_252 );
 ben_ext_write.g_val(253) := ext_xml_encode( p_val_253 );
 ben_ext_write.g_val(254) := ext_xml_encode( p_val_254 );
 ben_ext_write.g_val(255) := ext_xml_encode( p_val_255 );
 ben_ext_write.g_val(256) := ext_xml_encode( p_val_256 );
 ben_ext_write.g_val(257) := ext_xml_encode( p_val_257 );
 ben_ext_write.g_val(258) := ext_xml_encode( p_val_258 );
 ben_ext_write.g_val(259) := ext_xml_encode( p_val_259 );
 ben_ext_write.g_val(260) := ext_xml_encode( p_val_260 );
 ben_ext_write.g_val(261) := ext_xml_encode( p_val_261 );
 ben_ext_write.g_val(262) := ext_xml_encode( p_val_262 );
 ben_ext_write.g_val(263) := ext_xml_encode( p_val_263 );
 ben_ext_write.g_val(264) := ext_xml_encode( p_val_264 );
 ben_ext_write.g_val(265) := ext_xml_encode( p_val_265 );
 ben_ext_write.g_val(266) := ext_xml_encode( p_val_266 );
 ben_ext_write.g_val(267) := ext_xml_encode( p_val_267 );
 ben_ext_write.g_val(268) := ext_xml_encode( p_val_268 );
 ben_ext_write.g_val(269) := ext_xml_encode( p_val_269 );
 ben_ext_write.g_val(270) := ext_xml_encode( p_val_270 );
 ben_ext_write.g_val(271) := ext_xml_encode( p_val_271 );
 ben_ext_write.g_val(272) := ext_xml_encode( p_val_272 );
 ben_ext_write.g_val(273) := ext_xml_encode( p_val_273 );
 ben_ext_write.g_val(274) := ext_xml_encode( p_val_274 );
 ben_ext_write.g_val(275) := ext_xml_encode( p_val_275 );
 ben_ext_write.g_val(276) := ext_xml_encode( p_val_276 );
 ben_ext_write.g_val(277) := ext_xml_encode( p_val_277 );
 ben_ext_write.g_val(278) := ext_xml_encode( p_val_278 );
 ben_ext_write.g_val(279) := ext_xml_encode( p_val_279 );
 ben_ext_write.g_val(280) := ext_xml_encode( p_val_280 );
 ben_ext_write.g_val(281) := ext_xml_encode( p_val_281 );
 ben_ext_write.g_val(282) := ext_xml_encode( p_val_282 );
 ben_ext_write.g_val(283) := ext_xml_encode( p_val_283 );
 ben_ext_write.g_val(284) := ext_xml_encode( p_val_284 );
 ben_ext_write.g_val(285) := ext_xml_encode( p_val_285 );
 ben_ext_write.g_val(286) := ext_xml_encode( p_val_286 );
 ben_ext_write.g_val(287) := ext_xml_encode( p_val_287 );
 ben_ext_write.g_val(288) := ext_xml_encode( p_val_288 );
 ben_ext_write.g_val(289) := ext_xml_encode( p_val_289 );
 ben_ext_write.g_val(290) := ext_xml_encode( p_val_290 );
 ben_ext_write.g_val(291) := ext_xml_encode( p_val_291 );
 ben_ext_write.g_val(292) := ext_xml_encode( p_val_292 );
 ben_ext_write.g_val(293) := ext_xml_encode( p_val_293 );
 ben_ext_write.g_val(294) := ext_xml_encode( p_val_294 );
 ben_ext_write.g_val(295) := ext_xml_encode( p_val_295 );
 ben_ext_write.g_val(296) := ext_xml_encode( p_val_296 );
 ben_ext_write.g_val(297) := ext_xml_encode( p_val_297 );
 ben_ext_write.g_val(298) := ext_xml_encode( p_val_298 );
 ben_ext_write.g_val(299) := ext_xml_encode( p_val_299 );
 ben_ext_write.g_val(300) := ext_xml_encode( p_val_300 );


--
hr_utility.set_location('Exiting'||l_proc, 15);
--
--
end load_arrays;
-----------------------------------------------------------------------------

Procedure MAIN
          (p_output_name      in varchar2,
           p_drctry_name      in varchar2,
           p_ext_rslt_id      in number,
           p_output_type      in varchar2,
           p_xdo_template_id  in number  ,
           p_cm_display_flag  in varchar2 default null,
           p_rec_count        in out NOCOPY number ,
           p_source           in varchar2 default 'BENXWRIT'    ) is

--
--
file_handle utl_file.file_type;
--
cursor c_xrd is
  select xrd.ext_rcd_id,
         xrd.person_id,
         xrd.val_01,
         xrd.val_02,
         xrd.val_03,
         xrd.val_04,
         xrd.val_05,
         xrd.val_06,
         xrd.val_07,
         xrd.val_08,
         xrd.val_09,
         xrd.val_10,
         xrd.val_11,
         xrd.val_12,
         xrd.val_13,
         xrd.val_14,
         xrd.val_15,
         xrd.val_16,
         xrd.val_17,
         xrd.val_18,
         xrd.val_19,
         xrd.val_20,
         xrd.val_21,
         xrd.val_22,
         xrd.val_23,
         xrd.val_24,
         xrd.val_25,
         xrd.val_26,
         xrd.val_27,
         xrd.val_28,
         xrd.val_29,
         xrd.val_30,
         xrd.val_31,
         xrd.val_32,
         xrd.val_33,
         xrd.val_34,
         xrd.val_35,
         xrd.val_36,
         xrd.val_37,
         xrd.val_38,
         xrd.val_39,
         xrd.val_40,
         xrd.val_41,
         xrd.val_42,
         xrd.val_43,
         xrd.val_44,
         xrd.val_45,
         xrd.val_46,
         xrd.val_47,
         xrd.val_48,
         xrd.val_49,
         xrd.val_50,
         xrd.val_51,
         xrd.val_52,
         xrd.val_53,
         xrd.val_54,
         xrd.val_55,
         xrd.val_56,
         xrd.val_57,
         xrd.val_58,
         xrd.val_59,
         xrd.val_60,
         xrd.val_61,
         xrd.val_62,
         xrd.val_63,
         xrd.val_64,
         xrd.val_65,
         xrd.val_66,
         xrd.val_67,
         xrd.val_68,
         xrd.val_69,
         xrd.val_70,
         xrd.val_71,
         xrd.val_72,
         xrd.val_73,
         xrd.val_74,
         xrd.val_75,
         xrd.val_76,
         xrd.val_77,
         xrd.val_78,
         xrd.val_79,
         xrd.val_80,
         xrd.val_81,
         xrd.val_82,
         xrd.val_83,
         xrd.val_84,
         xrd.val_85,
         xrd.val_86,
         xrd.val_87,
         xrd.val_88,
         xrd.val_89,
         xrd.val_90,
         xrd.val_91,
         xrd.val_92,
         xrd.val_93,
         xrd.val_94,
         xrd.val_95,
         xrd.val_96,
         xrd.val_97,
         xrd.val_98,
         xrd.val_99,
         xrd.val_100,
         xrd.val_101,
         xrd.val_102,
         xrd.val_103,
         xrd.val_104,
         xrd.val_105,
         xrd.val_106,
         xrd.val_107,
         xrd.val_108,
         xrd.val_109,
         xrd.val_110,
         xrd.val_111,
         xrd.val_112,
         xrd.val_113,
         xrd.val_114,
         xrd.val_115,
         xrd.val_116,
         xrd.val_117,
         xrd.val_118,
         xrd.val_119,
         xrd.val_120,
         xrd.val_121,
         xrd.val_122,
         xrd.val_123,
         xrd.val_124,
         xrd.val_125,
         xrd.val_126,
         xrd.val_127,
         xrd.val_128,
         xrd.val_129,
         xrd.val_130,
         xrd.val_131,
         xrd.val_132,
         xrd.val_133,
         xrd.val_134,
         xrd.val_135,
         xrd.val_136,
         xrd.val_137,
         xrd.val_138,
         xrd.val_139,
         xrd.val_140,
         xrd.val_141,
         xrd.val_142,
         xrd.val_143,
         xrd.val_144,
         xrd.val_145,
         xrd.val_146,
         xrd.val_147,
         xrd.val_148,
         xrd.val_149,
         xrd.val_150,
         xrd.val_151,
         xrd.val_152,
         xrd.val_153,
         xrd.val_154,
         xrd.val_155,
         xrd.val_156,
         xrd.val_157,
         xrd.val_158,
         xrd.val_159,
         xrd.val_160,
         xrd.val_161,
         xrd.val_162,
         xrd.val_163,
         xrd.val_164,
         xrd.val_165,
         xrd.val_166,
         xrd.val_167,
         xrd.val_168,
         xrd.val_169,
         xrd.val_170,
         xrd.val_171,
         xrd.val_172,
         xrd.val_173,
         xrd.val_174,
         xrd.val_175,
         xrd.val_176,
         xrd.val_177,
         xrd.val_178,
         xrd.val_179,
         xrd.val_180,
         xrd.val_181,
         xrd.val_182,
         xrd.val_183,
         xrd.val_184,
         xrd.val_185,
         xrd.val_186,
         xrd.val_187,
         xrd.val_188,
         xrd.val_189,
         xrd.val_190,
         xrd.val_191,
         xrd.val_192,
         xrd.val_193,
         xrd.val_194,
         xrd.val_195,
         xrd.val_196,
         xrd.val_197,
         xrd.val_198,
         xrd.val_199,
         xrd.val_200,
         xrd.val_201,
         xrd.val_202,
         xrd.val_203,
         xrd.val_204,
         xrd.val_205,
         xrd.val_206,
         xrd.val_207,
         xrd.val_208,
         xrd.val_209,
         xrd.val_210,
         xrd.val_211,
         xrd.val_212,
         xrd.val_213,
         xrd.val_214,
         xrd.val_215,
         xrd.val_216,
         xrd.val_217,
         xrd.val_218,
         xrd.val_219,
         xrd.val_220,
         xrd.val_221,
         xrd.val_222,
         xrd.val_223,
         xrd.val_224,
         xrd.val_225,
         xrd.val_226,
         xrd.val_227,
         xrd.val_228,
         xrd.val_229,
         xrd.val_230,
         xrd.val_231,
         xrd.val_232,
         xrd.val_233,
         xrd.val_234,
         xrd.val_235,
         xrd.val_236,
         xrd.val_237,
         xrd.val_238,
         xrd.val_239,
         xrd.val_240,
         xrd.val_241,
         xrd.val_242,
         xrd.val_243,
         xrd.val_244,
         xrd.val_245,
         xrd.val_246,
         xrd.val_247,
         xrd.val_248,
         xrd.val_249,
         xrd.val_250,
         xrd.val_251,
         xrd.val_252,
         xrd.val_253,
         xrd.val_254,
         xrd.val_255,
         xrd.val_256,
         xrd.val_257,
         xrd.val_258,
         xrd.val_259,
         xrd.val_260,
         xrd.val_261,
         xrd.val_262,
         xrd.val_263,
         xrd.val_264,
         xrd.val_265,
         xrd.val_266,
         xrd.val_267,
         xrd.val_268,
         xrd.val_269,
         xrd.val_270,
         xrd.val_271,
         xrd.val_272,
         xrd.val_273,
         xrd.val_274,
         xrd.val_275,
         xrd.val_276,
         xrd.val_277,
         xrd.val_278,
         xrd.val_279,
         xrd.val_280,
         xrd.val_281,
         xrd.val_282,
         xrd.val_283,
         xrd.val_284,
         xrd.val_285,
         xrd.val_286,
         xrd.val_287,
         xrd.val_288,
         xrd.val_289,
         xrd.val_290,
         xrd.val_291,
         xrd.val_292,
         xrd.val_293,
         xrd.val_294,
         xrd.val_295,
         xrd.val_296,
         xrd.val_297,
         xrd.val_298,
         xrd.val_299,
         xrd.val_300,
         xrf.seq_num,
         xrd.group_val_01
 from   ben_ext_rslt_dtl xrd,
        ben_ext_rslt xrs,
        ben_ext_dfn xdf,
        ben_ext_rcd_in_file xrf
 where  xrd.ext_rslt_id = p_ext_rslt_id
 and  xrd.ext_rslt_id = xrs.ext_rslt_id
 and  xrs.ext_dfn_id = xdf.ext_dfn_id
 and  xdf.ext_file_id = xrf.ext_file_id
 and  xrd.ext_rcd_id = xrf.ext_rcd_id
 and (xrd.ext_rcd_in_file_id is null
      or xrd.ext_rcd_in_file_id = xrf.ext_rcd_in_file_id ) -- or condition taken care of previous results
 and  xrf.hide_flag = 'N'
 order by xrd.group_val_01,
          xrd.group_val_02,
          xrd.prmy_sort_val,
          xrd.scnd_sort_val,
          xrd.thrd_sort_val,
          xrf.seq_num ;  -- this is addedd  ther are  many time header may not sorted in order

 cursor c_ext_file is
   select xdf.ext_file_id,
          xdf.name,
          xdf.xml_tag_name,
          xdf.data_typ_cd ,
          xdf.cm_display_flag,
          xrs.eff_dt,
          xrs.run_strt_dt,
          xrs.run_end_dt,
          xfi.xml_tag_name file_xml_tag_name ,
         nvl( xrs.xdo_template_id, xdf.xdo_template_id ) xdo_template_id
   from  ben_Ext_dfn xdf,
         ben_Ext_rslt xrs,
         ben_ext_file xfi
   where xrs.ext_rslt_id = p_ext_rslt_id
     and xrs.ext_dfn_id  = xdf.ext_dfn_id
     and xdf.ext_file_id = xfi.ext_file_id ;

   l_ext_file c_ext_file%rowtype ;

  cursor c_ext_rcd ( c_ext_file_id number ,
                     c_ext_rcd_id  number ) is
   select  rcd.name ,
           rcd.xml_tag_name ,
           erf.seq_num,
           rcd.rcd_type_cd,
           erf.hide_flag ,
           rcd.LOW_LVL_CD
     from ben_ext_rcd_in_file  erf ,
          ben_ext_rcd rcd
    where erf.ext_file_id  = c_ext_file_id
      and erf.ext_rcd_id   = c_ext_rcd_id
      and rcd.ext_rcd_id   = erf.ext_rcd_id
      order by erf.seq_num ;
 l_ext_rcd c_ext_rcd%rowtype ;

  cursor c_elmt (c_ext_rcd_id number) is
     select elm.name,
            elm.xml_tag_name,
            rcd.seq_num,
            elm.data_elmt_typ_cd,
            elm.max_length_num,
            elm.frmt_mask_cd,
            elm.just_cd
            from   ben_ext_data_elmt_in_rcd rcd ,
             ben_ext_data_elmt elm
             where  rcd.ext_rcd_id = c_ext_rcd_id
             and  elm.ext_data_elmt_id = rcd.ext_data_elmt_id
             and  nvl(rcd.hide_flag,'N')  = 'N'
             order by rcd.seq_num;

   cursor c_defa_tags is
     select lookup_code ,
            meaning
       from hr_lookups
       where lookup_type = 'BEN_EXT_XML_TAGS' ;



   l_elm_xml_tag_name ben_ext_data_elmt.xml_tag_name%type ;
   l_elm_name         ben_ext_data_elmt.name%type ;
   l_elmt_seq_num     ben_ext_data_elmt_in_rcd.seq_num%type ;
   l_elm_typ_cd       ben_ext_data_elmt.data_elmt_typ_cd%type ;
   l_elm_max_length   ben_ext_data_elmt.max_length_num%type ;
   l_elm_frmt_mask    ben_ext_data_elmt.frmt_mask_cd%type ;
   l_elm_just_cd      ben_ext_data_elmt.just_cd%type      ;
   l_elm_val          ben_ext_rslt_dtl.val_01%type ;
   l_rec_num          number := 0 ;
   l_output_name      ben_ext_rslt.output_name%type ;
   l_file_name        ben_ext_rslt.output_name%type ;
   l_var  varchar2(4000) ;
   l_new_rec  number := -1 ;
   l_elmt_defa_tag    ben_ext_data_elmt.xml_tag_name%type ;
   l_rcd_defa_tag     ben_ext_data_elmt.xml_tag_name%type ;
   l_rcdset_defa_tag  ben_ext_data_elmt.xml_tag_name%type ;
   l_file_defa_tag    ben_ext_data_elmt.xml_tag_name%type ;
   l_dfn_defa_tag     ben_ext_data_elmt.xml_tag_name%type ;
   l_xdo_template_id  number ;
   l_cm_display_flag   varchar2(30) ;
   --
   l_old_person_id    number := -1  ;

  cursor c_per_info (p_person_id number, p_effective_date date) is
  select full_name,
         employee_number
  from per_all_people_f
  where person_id = p_person_id
  and p_effective_date between  EFFECTIVE_START_DATE and
nvl(EFFECTIVE_END_DATE,trunc(sysdate));
  l_name             per_all_people_f.full_name%type ;
  l_employee_number  per_all_people_f.employee_number%type ;

   --
  l_proc     varchar2(72) := g_package||'main';
  l_max_ext_line_size  Number := 32767 ;
  -- pdf cahnges
  l_pdf_output_name  ben_ext_rslt.output_name%type ;
  l_extn_name        varchar2(50) ;
  l_prv_low_lvl_cd   varchar2(5) ;
  l_low_lvl_name     varchar2(250) ;
  l_low_lvl_cd     varchar2(250) ;
  l_Low_lvl_grouping varchar2(1) := 'N' ;
  l_prev_levl_found  varchar2(1) := 'N' ;


  l_directory_name   varchar2(2000) ;

  cursor c_fnd_dir is
  select outfile_name
  from  fnd_concurrent_requests
  where  request_id =  fnd_global.conc_request_id ;
begin
--
  hr_Utility.set_location('Entering'||l_proc, 5);

  fnd_profile.get( NAME => 'ICX_CLIENT_IANA_ENCODING'
                   ,VAL  => g_iana_char_set );
  if g_iana_char_set is null then
     g_iana_char_set := 'UTF-8'  ;
  end if ;

  hr_Utility.set_location('iana character  '|| l_output_name, 5);

    --- Process for xml_file l_xml_result
     l_output_name := rtrim(p_output_name);

    --- to create extract schema and stylesheet n output file name

    l_file_name :=   l_output_name ;
    if instr( l_output_name,'.',-1) > 1 then
       l_file_name := substr(l_output_name,1,instr( l_output_name,'.',-1)-1) ;
    end if ;


    -- we can not create same file for xml and pdf
    -- so pdf created in given name and pdf changed by adding xml to the end
    -- of the file extension is xml then add .xml to then , else
    -- create the file name  with xml extension
    if  p_output_type <> 'X' then
        l_pdf_output_name   :=  l_output_name ;
        l_extn_name  := substr(l_pdf_output_name,instr( l_pdf_output_name,'.',-1)+1) ;
        if upper(l_extn_name) = 'XML' then
            l_output_name :=  l_output_name || '.xml' ;
        else
           l_output_name := l_file_name || '.xml' ;
        end if ;
         l_Low_lvl_grouping := 'Y' ;   -- for pdf output subgrouping enabled
    end if ;


    --- intialise the default tag variable and validate variable
    --- if the lookup variable is null the system does not throw errror
    --- because the variable may not be used if the tags are fefined in extract
    for i in  c_defa_tags
    Loop
       if i.lookup_code = 'EXT_DFN' then
          l_dfn_defa_tag := i.meaning ;
       end if ;
       if i.lookup_code = 'EXT_FILE' then
          l_file_defa_tag := i.meaning ;
       end if ;
       if i.lookup_code = 'EXT_RCD' then
          l_rcd_defa_tag := i.meaning ;
       end if ;
       if i.lookup_code = 'EXT_RCD_SET' then
          l_rcdset_defa_tag := i.meaning ;
       end if ;
       if i.lookup_code = 'EXT_ELMT' then
          l_elmt_defa_tag := i.meaning ;
       end if ;

    end loop ;
    --- if the default element variable are not null
    --- validate the tags
    if l_dfn_defa_tag is not null then
        ben_xel_bus.chk_xml_name_format
          ( p_xml_tag_name    => l_dfn_defa_tag
          ) ;
    end if ;

    if l_file_defa_tag is not null then
        ben_xel_bus.chk_xml_name_format
          ( p_xml_tag_name    => l_file_defa_tag
          ) ;
    end if ;

    if l_rcd_defa_tag is not null then
        ben_xel_bus.chk_xml_name_format
          ( p_xml_tag_name    => l_rcd_defa_tag
          ) ;
    end if ;

    if l_rcdset_defa_tag is not null then
        ben_xel_bus.chk_xml_name_format
          ( p_xml_tag_name    => l_rcdset_defa_tag
          ) ;
    end if ;

    if l_elmt_defa_tag is not null then
        ben_xel_bus.chk_xml_name_format
          ( p_xml_tag_name    => l_elmt_defa_tag
          ) ;
    end if ;


    --- Extract File/Definition Information
    open c_ext_file ;
    fetch c_ext_file into l_ext_file ;
    close c_ext_file ;


    ---
    l_xdo_template_id  :=  nvl(p_xdo_template_id , l_ext_file.xdo_template_id ) ;
    l_cm_display_flag  :=  nvl(p_cm_display_flag , l_ext_file.cm_display_flag ) ;
    --l_cm_display_flag  :=  p_cm_display_flag ;

    l_directory_name := p_drctry_name  ;
    if p_cm_display_flag = 'Y' then
       open c_fnd_dir ;
       fetch c_fnd_dir into l_directory_name ;
       close c_fnd_dir ;
       l_directory_name := rtrim(l_directory_name,'o'||fnd_global.conc_request_id||'.out')  ;
       l_directory_name := substr( l_directory_name, 1, length( l_directory_name)-1) ;
       l_file_name      := 'o'||fnd_global.conc_request_id ;
       l_output_name    := 'o'||fnd_global.conc_request_id||'.out' ;
    end if ;


    if l_cm_display_flag <> 'Y' then
       file_handle := utl_file.fopen (l_directory_name ,l_output_name,'w' , l_max_ext_line_size );
    end if ;

    g_dfn_tag  := nvl(l_ext_file.xml_tag_name,l_dfn_defa_tag) ;
    g_file_tag := nvl(l_ext_file.file_xml_tag_name,l_file_defa_tag ) ;
    -- when  the output type is pdf dont write the header
    if  p_output_type <> 'X' then

      l_var :=  '<?xml version="1.0" encoding="'||g_iana_char_set||'"?>';
      l_var := l_var || '<'||nvl(l_ext_file.xml_tag_name,l_dfn_defa_tag )||'>' ;
      if l_cm_display_flag =  'Y' then
         fnd_file.put_line(fnd_file.OUTPUT, l_var);
      else
         utl_file.put_line(file_handle, l_var);
      end if ;
    else
      --- Write the xml header
        if l_cm_display_flag =  'Y' then
           fnd_file.put_line(fnd_file.OUTPUT, '<?xml version="1.0" encoding="'||g_iana_char_set||'"?>');
        else
            utl_file.put_line(file_handle, '<?xml version="1.0" encoding="'||g_iana_char_set||'"?>');
        end if ;

      --utl_file.put_line(file_handle, '<?xml version="1.0" encoding="'||g_iana_char_set||'"?>');
      -- Write the refference to style sheet, assume the style sheet in current directory
      if l_cm_display_flag =  'Y' then
         null ;
         --fnd_file.put_line(fnd_file.OUTPUT, '<?xml-stylesheet type="text/xsl" href="'||nvl(l_file_name,'benxxssh')||'.xsl"?>');
      else

         utl_file.put_line(file_handle, '<?xml-stylesheet type="text/xsl" href="'||nvl(l_file_name,'benxxssh')||'.xsl"?>');
      end if ;

     -- utl_file.put_line(file_handle, '<?xml-stylesheet type="text/xsl" href="'||nvl(l_file_name,'benxxssh')||'.xsl"?>');

      --  write the xml root element  with reference to Schemea , the assumption is
      --  again the schema doc is avaialble in currect dir

      --l_var:='<ext:'||nvl(l_ext_file.xml_tag_name,l_dfn_defa_tag )||' xmlns:ext="http://www.oracle.com/xml/OAB/ext"' ;
      --l_var:='<'||nvl(l_ext_file.xml_tag_name,l_dfn_defa_tag )||' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" ' ;
      --utl_file.put_line(file_handle, l_var);

      --if l_cm_display_flag =  'Y' then
      --   fnd_file.put_line(fnd_file.OUTPUT, l_var);
      --else
      --   utl_file.put_line(file_handle, l_var);
     -- end if ;

      ---utl_file.put_line(file_handle, '   xmlns="http://www.oracle.com/xml/OAB/ext"  ');
      --- utl_file.put_line(file_handle, '   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"  ');
      l_var:='<'||nvl(l_ext_file.xml_tag_name,l_dfn_defa_tag )||' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" ' ;
      if l_cm_display_flag =   'Y' then
         --fnd_file.put_line(fnd_file.OUTPUT, l_var);
         --fnd_file.put_line(fnd_file.OUTPUT, '   xsi:noNamespaceSchemaLocation="'|| nvl(l_file_name,'benxxsch')||'.xsd">');
         null ;
      else
         utl_file.put_line(file_handle, l_var);
         utl_file.put_line(file_handle, '   xsi:noNamespaceSchemaLocation="'|| nvl(l_file_name,'benxxsch')||'.xsd">');
      end if ;

   end if ;

    -- write file/definition information
    l_var :=  '<' ||nvl(l_ext_file.file_xml_tag_name,l_file_defa_tag) || ' ext_dfn_name="'||l_ext_file.name || '" '||
                'ext_type="' || l_ext_file.data_typ_cd || '" '||
                'effective_date="'||l_ext_file.eff_dt|| '" '||
                'start_time="' || l_ext_file.run_strt_dt || '" '||
                'end_time="' || l_ext_file.run_end_dt || '" > '  ;

    --utl_file.put_line(file_handle, l_var );

     if l_cm_display_flag =  'Y' then
         fnd_file.put_line(fnd_file.OUTPUT, l_var);
      else
         utl_file.put_line(file_handle, l_var);
      end if ;

    p_rec_count :=  0 ;
    ---- Loop the the record
    for l_xrd in c_xrd loop

          -----
         load_arrays
        (l_xrd.ext_rcd_id,
         l_xrd.val_01,
         l_xrd.val_02,
         l_xrd.val_03,
         l_xrd.val_04,
         l_xrd.val_05,
         l_xrd.val_06,
         l_xrd.val_07,
         l_xrd.val_08,
         l_xrd.val_09,
         l_xrd.val_10,
         l_xrd.val_11,
         l_xrd.val_12,
         l_xrd.val_13,
         l_xrd.val_14,
         l_xrd.val_15,
         l_xrd.val_16,
         l_xrd.val_17,
         l_xrd.val_18,
         l_xrd.val_19,
         l_xrd.val_20,
         l_xrd.val_21,
         l_xrd.val_22,
         l_xrd.val_23,
         l_xrd.val_24,
         l_xrd.val_25,
         l_xrd.val_26,
         l_xrd.val_27,
         l_xrd.val_28,
         l_xrd.val_29,
         l_xrd.val_30,
         l_xrd.val_31,
         l_xrd.val_32,
         l_xrd.val_33,
         l_xrd.val_34,
         l_xrd.val_35,
         l_xrd.val_36,
         l_xrd.val_37,
         l_xrd.val_38,
         l_xrd.val_39,
         l_xrd.val_40,
         l_xrd.val_41,
         l_xrd.val_42,
         l_xrd.val_43,
         l_xrd.val_44,
         l_xrd.val_45,
         l_xrd.val_46,
         l_xrd.val_47,
         l_xrd.val_48,
         l_xrd.val_49,
         l_xrd.val_50,
         l_xrd.val_51,
         l_xrd.val_52,
         l_xrd.val_53,
         l_xrd.val_54,
         l_xrd.val_55,
         l_xrd.val_56,
         l_xrd.val_57,
         l_xrd.val_58,
         l_xrd.val_59,
         l_xrd.val_60,
         l_xrd.val_61,
         l_xrd.val_62,
         l_xrd.val_63,
         l_xrd.val_64,
         l_xrd.val_65,
         l_xrd.val_66,
         l_xrd.val_67,
         l_xrd.val_68,
         l_xrd.val_69,
         l_xrd.val_70,
         l_xrd.val_71,
         l_xrd.val_72,
         l_xrd.val_73,
         l_xrd.val_74,
         l_xrd.val_75,
         l_xrd.val_76,
         l_xrd.val_77,
         l_xrd.val_78,
         l_xrd.val_79,
         l_xrd.val_80,
         l_xrd.val_81,
         l_xrd.val_82,
         l_xrd.val_83,
         l_xrd.val_84,
         l_xrd.val_85,
         l_xrd.val_86,
         l_xrd.val_87,
         l_xrd.val_88,
         l_xrd.val_89,
         l_xrd.val_90,
         l_xrd.val_91,
         l_xrd.val_92,
         l_xrd.val_93,
         l_xrd.val_94,
         l_xrd.val_95,
         l_xrd.val_96,
         l_xrd.val_97,
         l_xrd.val_98,
         l_xrd.val_99,
         l_xrd.val_100,
         l_xrd.val_101,
         l_xrd.val_102,
         l_xrd.val_103,
         l_xrd.val_104,
         l_xrd.val_105,
         l_xrd.val_106,
         l_xrd.val_107,
         l_xrd.val_108,
         l_xrd.val_109,
         l_xrd.val_110,
         l_xrd.val_111,
         l_xrd.val_112,
         l_xrd.val_113,
         l_xrd.val_114,
         l_xrd.val_115,
         l_xrd.val_116,
         l_xrd.val_117,
         l_xrd.val_118,
         l_xrd.val_119,
         l_xrd.val_120,
         l_xrd.val_121,
         l_xrd.val_122,
         l_xrd.val_123,
         l_xrd.val_124,
         l_xrd.val_125,
         l_xrd.val_126,
         l_xrd.val_127,
         l_xrd.val_128,
         l_xrd.val_129,
         l_xrd.val_130,
         l_xrd.val_131,
         l_xrd.val_132,
         l_xrd.val_133,
         l_xrd.val_134,
         l_xrd.val_135,
         l_xrd.val_136,
         l_xrd.val_137,
         l_xrd.val_138,
         l_xrd.val_139,
         l_xrd.val_140,
         l_xrd.val_141,
         l_xrd.val_142,
         l_xrd.val_143,
         l_xrd.val_144,
         l_xrd.val_145,
         l_xrd.val_146,
         l_xrd.val_147,
         l_xrd.val_148,
         l_xrd.val_149,
         l_xrd.val_150,
         l_xrd.val_151,
         l_xrd.val_152,
         l_xrd.val_153,
         l_xrd.val_154,
         l_xrd.val_155,
         l_xrd.val_156,
         l_xrd.val_157,
         l_xrd.val_158,
         l_xrd.val_159,
         l_xrd.val_160,
         l_xrd.val_161,
         l_xrd.val_162,
         l_xrd.val_163,
         l_xrd.val_164,
         l_xrd.val_165,
         l_xrd.val_166,
         l_xrd.val_167,
         l_xrd.val_168,
         l_xrd.val_169,
         l_xrd.val_170,
         l_xrd.val_171,
         l_xrd.val_172,
         l_xrd.val_173,
         l_xrd.val_174,
         l_xrd.val_175,
         l_xrd.val_176,
         l_xrd.val_177,
         l_xrd.val_178,
         l_xrd.val_179,
         l_xrd.val_180,
         l_xrd.val_181,
         l_xrd.val_182,
         l_xrd.val_183,
         l_xrd.val_184,
         l_xrd.val_185,
         l_xrd.val_186,
         l_xrd.val_187,
         l_xrd.val_188,
         l_xrd.val_189,
         l_xrd.val_190,
         l_xrd.val_191,
         l_xrd.val_192,
         l_xrd.val_193,
         l_xrd.val_194,
         l_xrd.val_195,
         l_xrd.val_196,
         l_xrd.val_197,
         l_xrd.val_198,
         l_xrd.val_199,
         l_xrd.val_200,
         l_xrd.val_201,
         l_xrd.val_202,
         l_xrd.val_203,
         l_xrd.val_204,
         l_xrd.val_205,
         l_xrd.val_206,
         l_xrd.val_207,
         l_xrd.val_208,
         l_xrd.val_209,
         l_xrd.val_210,
         l_xrd.val_211,
         l_xrd.val_212,
         l_xrd.val_213,
         l_xrd.val_214,
         l_xrd.val_215,
         l_xrd.val_216,
         l_xrd.val_217,
         l_xrd.val_218,
         l_xrd.val_219,
         l_xrd.val_220,
         l_xrd.val_221,
         l_xrd.val_222,
         l_xrd.val_223,
         l_xrd.val_224,
         l_xrd.val_225,
         l_xrd.val_226,
         l_xrd.val_227,
         l_xrd.val_228,
         l_xrd.val_229,
         l_xrd.val_230,
         l_xrd.val_231,
         l_xrd.val_232,
         l_xrd.val_233,
         l_xrd.val_234,
         l_xrd.val_235,
         l_xrd.val_236,
         l_xrd.val_237,
         l_xrd.val_238,
         l_xrd.val_239,
         l_xrd.val_240,
         l_xrd.val_241,
         l_xrd.val_242,
         l_xrd.val_243,
         l_xrd.val_244,
         l_xrd.val_245,
         l_xrd.val_246,
         l_xrd.val_247,
         l_xrd.val_248,
         l_xrd.val_249,
         l_xrd.val_250,
         l_xrd.val_251,
         l_xrd.val_252,
         l_xrd.val_253,
         l_xrd.val_254,
         l_xrd.val_255,
         l_xrd.val_256,
         l_xrd.val_257,
         l_xrd.val_258,
         l_xrd.val_259,
         l_xrd.val_260,
         l_xrd.val_261,
         l_xrd.val_262,
         l_xrd.val_263,
         l_xrd.val_264,
         l_xrd.val_265,
         l_xrd.val_266,
         l_xrd.val_267,
         l_xrd.val_268,
         l_xrd.val_269,
         l_xrd.val_270,
         l_xrd.val_271,
         l_xrd.val_272,
         l_xrd.val_273,
         l_xrd.val_274,
         l_xrd.val_275,
         l_xrd.val_276,
         l_xrd.val_277,
         l_xrd.val_278,
         l_xrd.val_279,
         l_xrd.val_280,
         l_xrd.val_281,
         l_xrd.val_282,
         l_xrd.val_283,
         l_xrd.val_284,
         l_xrd.val_285,
         l_xrd.val_286,
         l_xrd.val_287,
         l_xrd.val_288,
         l_xrd.val_289,
         l_xrd.val_290,
         l_xrd.val_291,
         l_xrd.val_292,
         l_xrd.val_293,
         l_xrd.val_294,
         l_xrd.val_295,
         l_xrd.val_296,
         l_xrd.val_297,
         l_xrd.val_298,
         l_xrd.val_299,
         l_xrd.val_300,
         l_xrd.seq_num);
          --


         -- if person cahnged then close the record set too
         if  l_old_person_id <>  l_xrd.person_id then
             if  l_new_rec <> -1 then
                  l_new_rec := -2  ;
             end if ;
         end if ;




         p_rec_count := p_rec_count  + 1 ;

         -- for low level grouping every record start with record element not record set element
         if l_Low_lvl_grouping = 'N'  then
            if l_new_rec <> l_xrd.ext_rcd_id  then
                -- closing the element for previous  record
               if l_new_rec <> -1 then
                  hr_utility.set_location(' close record   ' || l_ext_rcd.xml_tag_name , 99 );

                  if l_cm_display_flag =  'Y' then
                     fnd_file.put_line(fnd_file.OUTPUT, '</'||nvl(l_ext_rcd.xml_tag_name,l_rcd_defa_tag)||'>');
                  else
                     utl_file.put_line(file_handle, '</'||nvl(l_ext_rcd.xml_tag_name,l_rcd_defa_tag)||'>');
                  end if ;

                  --utl_file.put_line(file_handle, '</'||nvl(l_ext_rcd.xml_tag_name,l_rcd_defa_tag)||'>');
                  ---- whether close the lowlevel code
               end if ;
            end if ;
         end if ;
         -- person level loop shoyld be closed after the record level loop
          if  l_old_person_id <>  l_xrd.person_id then
             if l_old_person_id <> -1 then
                 --- close the lowlevel code

                if l_Low_lvl_grouping = 'Y' then

                   l_prev_levl_found := 'N' ;
                   for j in REVERSE 1  .. g_low_lvl_tbl.count loop
                        --- whne the person level complete exist
                        --- or reach the sub group
                        if l_prv_low_lvl_cd = 'P' and g_low_lvl_tbl(j) <> 'P'
                           or  ( g_low_lvl_tbl(j) in ('PO','OR','PY','JB','LO') and
                                 nvl(l_xrd.group_val_01 ,'-1') =  nvl(g_prev_grop_val,'-1')  and
                                  l_xrd.group_val_01 <> '   '  )
                           then
                            hr_utility.set_location(' new person  ' || g_low_lvl_tbl(j) , 99 );
                            l_prv_low_lvl_cd := g_low_lvl_tbl(j) ;
                            l_prev_levl_found := 'Y' ;
                           exit ;
                        end if ;
                        l_prv_low_lvl_cd := g_low_lvl_tbl(j) ;
                        l_low_lvl_name := get_low_lvl_name(l_prv_low_lvl_cd) ;
                          hr_utility.set_location(' close level   ' || l_low_lvl_name , 99 );
                        l_var:= '</'||l_low_lvl_name  || '> '  ;
                        --utl_file.put_line(file_handle, l_var );
                        if l_cm_display_flag =  'Y' then
                            fnd_file.put_line(fnd_file.OUTPUT, l_var);
                        else
                            utl_file.put_line(file_handle, l_var);
                        end if ;
                        add_delete_sub_level('DELETE' ,  l_prv_low_lvl_cd ) ;
                   end loop ;
                   --- if previous level si 'p' assume the loop completed
                   --- so clear the  variables
                   if  l_prev_levl_found  = 'N' then
                      g_low_lvl_tbl.delete ;
                      l_prv_low_lvl_cd := null ;
                   end if ;
                else
                   -- l_Low_lvl_grouping
                 --utl_file.put_line(file_handle, '</'||'oabext_person_record_set' ||'>');
                  if l_cm_display_flag =  'Y' then
                     fnd_file.put_line(fnd_file.OUTPUT,  '</'||'oabext_person_record_set' ||'>' );
                  else
                     utl_file.put_line(file_handle,  '</'||'oabext_person_record_set' ||'>' );
                  end if ;
                end if ;
             end if ;
          end if ;



          -- person level starts before the  record level
          -- person level loop
          if l_old_person_id <>  l_xrd.person_id then
             --get the person name
             open c_per_info(l_xrd.person_id,l_ext_file.eff_dt) ;
             fetch c_per_info into l_name, l_employee_number ;
             close c_per_info ;
             if l_Low_lvl_grouping = 'N' then
                --utl_file.put_line(file_handle, '<'||'oabext_person_record_set'||'  person_name="'||ext_xml_encode(l_name)||
                --                      '"  employee_number="'|| l_employee_number||'">');
                 if l_cm_display_flag =  'Y' then
                    fnd_file.put_line(fnd_file.OUTPUT,  '<'||'oabext_person_record_set'||'  person_name="'||ext_xml_encode(l_name)||
                                      '"  employee_number="'|| l_employee_number||'">');
                 else
                     utl_file.put_line(file_handle,  '<'||'oabext_person_record_set'||'  person_name="'||ext_xml_encode(l_name)||
                                      '"  employee_number="'|| l_employee_number||'">');
                 end if ;

             end if ;
          end if ;
          l_old_person_id  := l_xrd.person_id ;



          -- start the record level after the person level
          if l_new_rec <> l_xrd.ext_rcd_id  then
             --- dont change the record for people change
             if l_new_rec <> -2 then
                l_rec_num :=  0 ;
             end if ;

             hr_utility.set_location(' new record  ' || l_xrd.ext_rcd_id , 99 );
             l_new_rec := l_xrd.ext_rcd_id ;

            --- Get the  Extract Record Information
            open c_ext_rcd( l_ext_file.ext_file_id ,
                             l_xrd.ext_rcd_id );
            fetch c_ext_rcd into l_ext_rcd ;
            close c_ext_rcd ;


            --- Skip the record which has hide attribute
            if nvl(l_ext_rcd.hide_flag,'N') <> 'Y'  then
               if l_Low_lvl_grouping = 'Y' then
                  --- decode to start the  lowlevel
                  -- when the previous level is not the same
                  if nvl(l_prv_low_lvl_cd,'-1') <> l_ext_rcd.low_lvl_cd   then
                     l_low_lvl_name := get_low_lvl_name(l_ext_rcd.low_lvl_cd) ;
                     -- current level is sub group of previous levle
                     if ( determine_sub_low_lvl (l_prv_low_lvl_cd,l_ext_rcd.low_lvl_cd, l_xrd.group_val_01)) = 'Y'  then

                         -- for every person or first record get the person infromation as attribute
                         if l_prv_low_lvl_cd is null then
                            l_var := '<'||l_low_lvl_name  || ' Low_Level_Code="' ||l_ext_rcd.low_lvl_cd||
                                                         '"  person_name="'||ext_xml_encode(l_name)||
                                                         '"  employee_number="'|| l_employee_number|| '"> '  ;
                         else
                            l_low_lvl_name := get_low_lvl_name(l_ext_rcd.low_lvl_cd) ;
                            l_var := '<'||l_low_lvl_name  || ' Low_Level_Code="' ||l_ext_rcd.low_lvl_cd || '"> '  ;
                         end if ;

                         --utl_file.put_line(file_handle, l_var );
                         if l_cm_display_flag =  'Y' then
                            fnd_file.put_line(fnd_file.OUTPUT, l_var);
                         else
                            utl_file.put_line(file_handle, l_var);
                         end if ;

                         add_delete_sub_level('ADD' , l_ext_rcd.low_lvl_cd ) ;
                         l_prv_low_lvl_cd := l_ext_rcd.low_lvl_cd ;

                     else
                        -- when the   level not the same and not subgroup
                        -- close  the element till it find the same or subgroup
                        -- close the previous level
                        hr_utility.set_location('closing previous level' || l_prv_low_lvl_cd  , 99 );
                        l_prev_levl_found := 'N' ;
                        for j in REVERSE 1   ..  g_low_lvl_tbl.count  loop

                            l_prv_low_lvl_cd := g_low_lvl_tbl(j) ;
                             hr_utility.set_location('  prv '||l_prv_low_lvl_cd|| ' curr  '|| l_ext_rcd.low_lvl_cd , 99 ) ;
                            if  l_prv_low_lvl_cd = l_ext_rcd.low_lvl_cd and
                                nvl(l_xrd.group_val_01,'-1') =  nvl(g_prev_grop_val,'-1')   then
                                -- close the previous element and open a new element
                                l_low_lvl_name := get_low_lvl_name(l_ext_rcd.low_lvl_cd) ;
                                l_var:= '</'||l_low_lvl_name  || '> '  ;
                                --utl_file.put_line(file_handle, l_var );
                                if l_cm_display_flag =  'Y' then
                                   fnd_file.put_line(fnd_file.OUTPUT, l_var);
                                else
                                   utl_file.put_line(file_handle, l_var);
                                end if ;
                                l_low_lvl_name := get_low_lvl_name(l_ext_rcd.low_lvl_cd) ;
                                l_var := '<'||l_low_lvl_name  || ' Low_Level_Code="'|| l_ext_rcd.low_lvl_cd || '"> '  ;
                                --utl_file.put_line(file_handle, l_var );
                                if l_cm_display_flag =  'Y' then
                                   fnd_file.put_line(fnd_file.OUTPUT, l_var);
                                else
                                   utl_file.put_line(file_handle, l_var);
                                end if ;

                                 l_prev_levl_found := 'Y' ;
                                exit ;

                           elsif (determine_sub_low_lvl(l_prv_low_lvl_cd,l_ext_rcd.low_lvl_cd,l_xrd.group_val_01)) ='Y' then
                                l_low_lvl_name := get_low_lvl_name(l_ext_rcd.low_lvl_cd) ;
                                l_var := '<'||l_low_lvl_name  || ' Low_Level_Code="'|| l_ext_rcd.low_lvl_cd || '"> '  ;
                                --utl_file.put_line(file_handle, l_var );
                                if l_cm_display_flag =  'Y' then
                                   fnd_file.put_line(fnd_file.OUTPUT, l_var);
                                else
                                   utl_file.put_line(file_handle, l_var);
                                end if ;
                                add_delete_sub_level('ADD' , l_ext_rcd.low_lvl_cd ) ;
                                l_prv_low_lvl_cd := l_ext_rcd.low_lvl_cd ;
                                l_prev_levl_found := 'Y' ;
                                exit ;
                            else
                                 add_delete_sub_level('DELETE' ,  l_prv_low_lvl_cd ) ;
                                 l_low_lvl_name := get_low_lvl_name(l_prv_low_lvl_cd) ;
                                 hr_utility.set_location( '  closingi prv levl  ' || l_low_lvl_name   , 99 ) ;
                                 l_var:= '</'||l_low_lvl_name  || '> '  ;
                                 --utl_file.put_line(file_handle, l_var );
                                if l_cm_display_flag =  'Y' then
                                   fnd_file.put_line(fnd_file.OUTPUT, l_var);
                                else
                                   utl_file.put_line(file_handle, l_var);
                                end if ;

                            end if ;
                         end loop ;
                         --- if the previous level not found then it is the new level
                         if l_prev_levl_found = 'N'  then
                            l_low_lvl_name := get_low_lvl_name(l_ext_rcd.low_lvl_cd) ;
                            l_var := '<'||l_low_lvl_name  || ' Low_Level_Code="'|| l_ext_rcd.low_lvl_cd || '"> '  ;
                            --utl_file.put_line(file_handle, l_var );
                            if l_cm_display_flag =  'Y' then
                                   fnd_file.put_line(fnd_file.OUTPUT, l_var);
                            else
                                   utl_file.put_line(file_handle, l_var);
                            end if ;
                            add_delete_sub_level('ADD' , l_ext_rcd.low_lvl_cd ) ;
                            l_prv_low_lvl_cd := l_ext_rcd.low_lvl_cd ;
                         end if ;


                     end if  ;
                  end if ;
                  -- l_Low_lvl_grouping
               else
               ---

                  l_var:= '<'||nvl(l_ext_rcd.xml_tag_name,l_rcd_defa_tag)||' ext_rec_name="'||l_ext_rcd.name || '" '||
                      'ext_rec_seq="' || l_ext_rcd.seq_num || '" '||
                      'ext_rec_type="'||l_ext_rcd.rcd_type_cd  || '" '||
                      'ext_rec_person="'||l_xrd.person_id  || '" > '  ;
                  --utl_file.put_line(file_handle, l_var );
                  if l_cm_display_flag =  'Y' then
                     fnd_file.put_line(fnd_file.OUTPUT, l_var);
                  else
                      utl_file.put_line(file_handle, l_var);
                  end if ;
                  load_tags(p_tag_table => g_rcd_tag_tbl ,
                        p_tag       => nvl(l_ext_rcd.xml_tag_name,l_rcd_defa_tag)
                         ) ;
               end if ;
             end if ;
          end if ;

          --- extract the detail only when the hide flag is 'N'
          if nvl(l_ext_rcd.hide_flag,'N') <> 'Y'  then
              ---- required columns information taken from Redord layout definition
              l_rec_num := l_rec_num + 1 ;
              -- for pdf there is no need for subgrouping under record
              if l_Low_lvl_grouping = 'Y' then
                 l_var:= '<'||nvl(l_ext_rcd.xml_tag_name,l_rcd_defa_tag)|| '>' ;
              else
                 l_var:=  '<oabext_record_set record_number=" ' || l_rec_num ||'">' ;
              end if ;
              --utl_file.put_line(file_handle, l_var);
              if l_cm_display_flag =  'Y' then
                 fnd_file.put_line(fnd_file.OUTPUT, l_var);
              else
                 utl_file.put_line(file_handle, l_var);
              end if ;
              --

              open c_elmt (l_xrd.ext_rcd_id) ;
              loop
                 fetch c_elmt into l_elm_name       ,
                                   l_elm_xml_tag_name,
	 			   l_elmt_seq_num  ,
				   l_elm_typ_cd    ,
				   l_elm_max_length,
				   l_elm_frmt_mask ,
				   l_elm_just_cd   ;
                 exit when  c_elmt%notfound ;

                 l_elm_val := ben_ext_write.g_val(l_elmt_seq_num) ;


                 l_var :=  '<'||nvl(l_elm_xml_tag_name,l_elmt_defa_tag) ;
                 -- dont get the attrib for PDF output , confuse the user to define the template
                 if l_Low_lvl_grouping = 'N' then

                    l_var := l_var ||' ext_elmt_name="' || l_elm_name  || '" '||
                               'ext_elmt_seq="'    || l_elmt_seq_num  || '" '||
                               'ext_elmt_type="'   || l_elm_typ_cd  || '" '||
                               'ext_elmt_length_="'|| l_elm_max_length  || '" '||
                               'ext_elmt_format="' || l_elm_frmt_mask  || '" '||
                               'ext_elmt_just="'   || l_elm_just_cd ||'" '  ;
                 end if ;

                 l_var := l_var|| '>'||l_elm_val||'</'||nvl(l_elm_xml_tag_name,l_elmt_defa_tag)||'>';
                 --

                 --utl_file.put_line(file_handle, l_var );
                if l_cm_display_flag =  'Y' then
                   fnd_file.put_line(fnd_file.OUTPUT, l_var);
                else
                   utl_file.put_line(file_handle, l_var);
                end if ;

                 Load_tags(p_tag_table => g_elmt_tag_tbl ,
                           p_tag       => nvl(l_elm_xml_tag_name,l_elmt_defa_tag)
                           ) ;

             end loop ;
             close c_elmt ;

             if l_Low_lvl_grouping = 'Y' then
                 l_var:= '</'||nvl(l_ext_rcd.xml_tag_name,l_rcd_defa_tag)||'>' ;
              else
                 l_var:=  '</oabext_record_set>' ;
              end if ;

             --utl_file.put_line(file_handle,l_var );
              if l_cm_display_flag =  'Y' then
                 fnd_file.put_line(fnd_file.OUTPUT, l_var);
              else
                 utl_file.put_line(file_handle, l_var);
              end if ;
           end if ;

      end loop ;
      --- Close the elements
      hr_utility.set_location ( ' out of loop ' , 99 ) ;

      if l_Low_lvl_grouping = 'Y' then
         for j in REVERSE 1 .. g_low_lvl_tbl.count  loop
             l_prv_low_lvl_cd := g_low_lvl_tbl(j) ;
             l_low_lvl_name := get_low_lvl_name(l_prv_low_lvl_cd) ;
             l_var:= '</'||l_low_lvl_name  || '> '  ;
             --utl_file.put_line(file_handle, l_var );
              if l_cm_display_flag =  'Y' then
                 fnd_file.put_line(fnd_file.OUTPUT, l_var);
              else
                 utl_file.put_line(file_handle, l_var);
              end if ;
          end loop ;
          g_low_lvl_tbl.delete ;
      else
         --utl_file.put_line(file_handle, '</'||nvl(l_ext_rcd.xml_tag_name,l_rcd_defa_tag)||'>');
         if l_cm_display_flag =  'Y' then
            fnd_file.put_line(fnd_file.OUTPUT, '</'||nvl(l_ext_rcd.xml_tag_name,l_rcd_defa_tag)||'>');
            fnd_file.put_line(fnd_file.OUTPUT,  '</'||'oabext_person_record_set' ||'>' );
         else
            utl_file.put_line(file_handle, '</'||nvl(l_ext_rcd.xml_tag_name,l_rcd_defa_tag)||'>');
            utl_file.put_line(file_handle, '</'||'oabext_person_record_set' ||'>');
         end if ;
         -- l_Low_lvl_grouping
         --utl_file.put_line(file_handle, '</'||'oabext_person_record_set' ||'>');
      end if ;

      --utl_file.put_line(file_handle,l_var );
      if l_cm_display_flag =  'Y' then
         fnd_file.put_line(fnd_file.OUTPUT, '</'||nvl(l_ext_file.file_xml_tag_name,l_file_defa_tag)||'>' );
         --fnd_file.put_line(fnd_file.OUTPUT, '</ext:'|| nvl(l_ext_file.xml_tag_name,l_dfn_defa_tag)||'>');
          if  p_output_type <> 'X' then
              fnd_file.put_line(fnd_file.OUTPUT,  '</'|| nvl(l_ext_file.xml_tag_name,l_dfn_defa_tag)||'>' );
          end if ;
      else
         utl_file.put_line(file_handle, '</'||nvl(l_ext_file.file_xml_tag_name,l_file_defa_tag)||'>');
         --utl_file.put_line(file_handle, '</ext:'|| nvl(l_ext_file.xml_tag_name,l_dfn_defa_tag)||'>');
         utl_file.put_line(file_handle, '</'|| nvl(l_ext_file.xml_tag_name,l_dfn_defa_tag)||'>');
         utl_file.fclose(file_handle);
      end if;


      if p_output_type <> 'X'   and  l_cm_display_flag <> 'Y'   then   --- pdf





         hr_utility.set_location( ' calling xdo ', 99 );
         write_xdo_pdf
            (p_drctry_name      =>  l_directory_name  ,
             p_pdf_output_name  =>  l_pdf_output_name,
             p_input_name       =>  l_output_name,
             p_template_id      =>  l_xdo_template_id,
             p_output_type      =>  p_output_type
             --p_cm_display_flag  =>  l_cm_display_flag
             );
      else

        ---- Calling the function write the schema  file in the current directory
        if l_cm_display_flag <>  'Y' then
           write_schema
             (p_drctry_name   => l_directory_name,
              p_file_name     => l_file_name,
              p_ext_rslt_id   => p_ext_rslt_id,
              p_ext_dfn_tag   => nvl(l_ext_file.xml_tag_name,l_dfn_defa_tag),
              p_ext_file_tag  => nvl(l_ext_file.file_xml_tag_name,l_file_defa_tag)) ;


           write_style_sheet
             (p_drctry_name   => l_directory_name,
              p_file_name     => l_file_name,
              p_ext_rslt_id   => p_ext_rslt_id,
              p_ext_dfn_tag   => nvl(l_ext_file.xml_tag_name,l_dfn_defa_tag),
              p_ext_file_tag  => nvl(l_ext_file.file_xml_tag_name,l_file_defa_tag)) ;
         end if ;
      end if ;

      /*
      if p_cm_display_flag = 'Y'  then
         update fnd_concurrent_requests
         set  output_file_type = 'XML'
          where request_id = fnd_global.conc_request_id  ;
          commit ;
     end if  ;
     */


hr_utility.set_location('Exiting'||l_proc, 15);
--
--
EXCEPTION
--
    WHEN utl_file.invalid_path then
        fnd_message.set_name('BEN', 'BEN_92254_UTL_INVLD_PATH');
        fnd_file.put_line(fnd_file.log, fnd_message.get);
        fnd_message.raise_error;
--
    WHEN utl_file.invalid_mode then
        fnd_message.set_name('BEN', 'BEN_92249_UTL_INVLD_MODE');
        fnd_file.put_line(fnd_file.log, fnd_message.get);
        fnd_message.raise_error;
--
    WHEN utl_file.invalid_filehandle then
        fnd_message.set_name('BEN', 'BEN_92250_UTL_INVLD_FILEHANDLE');
        fnd_file.put_line(fnd_file.log, fnd_message.get);
        fnd_message.raise_error;
--
    WHEN utl_file.invalid_operation then
        fnd_message.set_name('BEN', 'BEN_92251_UTL_INVLD_OPER');
        fnd_file.put_line(fnd_file.log, fnd_message.get);
        fnd_message.raise_error;
--
    WHEN utl_file.read_error then
        fnd_message.set_name('BEN', 'BEN_92252_UTL_READ_ERROR');
        fnd_file.put_line(fnd_file.log, fnd_message.get);
        fnd_message.raise_error;
--

    WHEN others THEN
       hr_utility.set_location( 'other exception raised ' , 99 ) ;
       fnd_message.set_name('PER','FFU10_GENERAL_ORACLE_ERROR');
       fnd_message.set_token('2',substr(sqlerrm,1,200));
       fnd_file.put_line(fnd_file.log, fnd_message.get);
       fnd_message.raise_error;
--
END  ;
--
END;

/
