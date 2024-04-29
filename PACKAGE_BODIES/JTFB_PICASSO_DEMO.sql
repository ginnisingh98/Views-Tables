--------------------------------------------------------
--  DDL for Package Body JTFB_PICASSO_DEMO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTFB_PICASSO_DEMO" AS
/* $Header: jtfbdemb.pls 120.2 2005/10/25 05:25:58 psanyal ship $ */

/* $Header: jtfbdemb.pls 120.2 2005/10/25 05:25:58 psanyal ship $ */
--
--
/*****************************************************************************/
-- Start Of Comments
--
-- Name
--   jtfb_picasso_demo
--
-- Purpose
--    This package consists of procedures and functions to populate Demo data.
--
-- Private functions
--    None
--
-- Private Procedures
--    None
--
-- Notes
--
-- History
--  15-MAY-2001, Pandian Athimoolam, Created the functions to return
--       the graph xaxis and yaxis label name
--  09-MAY-2001, Pandian Athimoolam, Created.
--
-- end of Comments


/*****************************************************************************/
-- Start of Package Globals
--
-- end of Global Package Globals
--
--
/*****************************************************************************/
-- Start of Private Methods Specification
--
--
/*****************************************************************************/
-- Start Of Comments
--
-- Name       : write_message
-- Type       : Private
-- Function:
--    This procedure writes message (typically debug)
--
-- Pre-Reqs:
--
-- Parameters:
--    p_message_text
--       in  varchar2
--       This is the descriptive part of the message.
--
-- Notes:
--
-- End Of Comments
procedure write_message(
     p_message_text  in varchar2
);
--
-- End of Private Methods Specification
--
--
procedure write_message(
     p_message_text  in varchar2
) is
begin
   null;
   --dbms_output.put_line(p_message_text);
exception
   when others then
      null;
      --dbms_output.put_line(p_message_text);
end write_message;
--
--
procedure load_jtfb_demo_bin(
   p_context in varchar2 default null
) is

   l_method_name  varchar2(80) := g_pkg_name || '.load_jtfb_demo_bin: ';
   l_bin_code     varchar2(20) := 'JTFB_DEMO_BIN';
   l_rowid        varchar2(256);
   l_p_objects    varchar2(50);  -- the objects param value
   l_object      varchar2(50);
begin
   IF p_context IS NOT NULL THEN
     -- parse p_context and populate the relevant rows into the temp table
     l_p_objects := jtfb_dcf.get_parameter_value(p_context,'JTFB_P_OBJECTS');
     -- this is a multi select parameter which returs a value like 'CAMPAIGNS~~LEADS'

     FOR i IN 1..jtfb_dcf.get_multiselect_count(l_p_objects) LOOP
       l_object := jtfb_dcf.get_multiselect_value(l_p_objects,i);

       IF l_object = 'CAMPAIGNS' THEN
         INSERT INTO jtfb_temp_bin(bin_code, col1, col2, col4, col6) VALUES(l_bin_code, 'CAMPAIGNS', 'Campaigns', '67', '4.0');
       END IF;

       IF l_object = 'LEADS' THEN
         INSERT INTO jtfb_temp_bin(bin_code, col1, col2, col4, col6) VALUES(l_bin_code, 'LEADS', 'Leads', '2,523', '-5.1');
       END IF;

       IF l_object = 'OPPORTUNITIES' THEN
         INSERT INTO jtfb_temp_bin(bin_code, col1, col2, col4, col6) VALUES(l_bin_code, 'OPPORTUNITIES', 'Opportunities', '1522', '4.1');
       END IF;

       IF l_object = 'QUOTES' THEN
         INSERT INTO jtfb_temp_bin(bin_code, col1, col2, col4, col6) VALUES(l_bin_code, 'QUOTES', 'Quotes', '954', '3.19');
       END IF;

       IF l_object = 'CUSTOMERS' THEN
         INSERT INTO jtfb_temp_bin(bin_code, col1, col2, col4, col6) VALUES(l_bin_code, 'CUSTOMERS', 'Customers', '3,154', '6.5');
       END IF;

     END LOOP;

   ELSE
   jtfb_temp_bin_pkg.insert_row(
        x_rowid     => l_rowid
      , x_bin_code  => l_bin_code
      , x_col1      => 'CAMPAIGNS'
      , x_col2      => 'Campaigns'
      , x_col4      => '67'
      , x_col6      => '4.0'
   );

   jtfb_temp_bin_pkg.insert_row(
        x_rowid     => l_rowid
      , x_bin_code  => l_bin_code
      , x_col1      => 'LEADS'
      , x_col2      => 'Leads'
      , x_col4      => '2523'
      , x_col6      => '-5.1'
   );

   jtfb_temp_bin_pkg.insert_row(
        x_rowid     => l_rowid
      , x_bin_code  => l_bin_code
      , x_col1      => 'OPPORTUNITIES'
      , x_col2      => 'Opportunities'
      , x_col4      => '1522'
      , x_col6      => '4.1'
   );

   jtfb_temp_bin_pkg.insert_row(
        x_rowid     => l_rowid
      , x_bin_code  => l_bin_code
      , x_col1      => 'QUOTES'
      , x_col2      => 'Quotes'
      , x_col4      => '954'
      , x_col6      => '3.19'
   );

   jtfb_temp_bin_pkg.insert_row(
        x_rowid     => l_rowid
      , x_bin_code  => l_bin_code
      , x_col1      => 'CUSTOMERS'
      , x_col2      => 'Customers'
      , x_col4      => '3154'
      , x_col6      => '6.5'
   );
   END IF;
exception
   when others then
      write_message(l_method_name || sqlerrm);
end load_jtfb_demo_bin;
--
--
procedure load_jtfb_demo_bin1(
   p_context in varchar2 default null
) is

   l_method_name  varchar2(80) := g_pkg_name || '.load_jtfb_demo_bin1: ';
   l_bin_code     varchar2(20) := 'JTFB_DEMO_BIN1';

begin
   insert into jtfb_temp_bin(bin_code, col1, col2, col4, col6)
      values(l_bin_code, 'APR-01', 'APR-01', '6', '4.0');
   insert into jtfb_temp_bin(bin_code, col1, col2, col4, col6)
      values(l_bin_code, 'MAR-01', 'MAR-01', '4', '2.1');
   insert into jtfb_temp_bin(bin_code, col1, col2, col4, col6)
      values(l_bin_code, 'FEB-01', 'FEB-01', '2', '5.0');
   insert into jtfb_temp_bin(bin_code, col1, col2, col4, col6)
      values(l_bin_code, 'JAN-01', 'JAN-01', '12', '8.0');
   insert into jtfb_temp_bin(bin_code, col1, col2, col4, col6)
      values(l_bin_code, 'DEC-00', 'DEC-00', '0', '0.0');

exception
   when others then
      write_message(l_method_name || sqlerrm);
end load_jtfb_demo_bin1;
--
--
procedure load_jtfb_demo_report(
   p_context in varchar2 default null
) is

   l_method_name  varchar2(80) := g_pkg_name || '.load_jtfb_demo_report: ';
   l_report_code  varchar2(20) := 'JTFB_DEMO_REPORT';
   l_rowid        varchar2(256);
   l_object       varchar2(256);

begin

   l_object := jtfb_dcf.get_parameter_value(p_context,'JTFB_P_OBJECTS');

   if (l_object = 'CAMPAIGNS')
   then
      jtfb_temp_report_pkg.insert_row(
           x_rowid     => l_rowid
         , x_report_code  => l_report_code
         , x_col1      => 'TOTAL'
         , x_col2      => 'Total'
         , x_col4      => '514'
         , x_col6      => '648'
         , x_col8      => '484'
         , x_col10     => '500'
         , x_col12     => '30.37'
      );

      jtfb_temp_report_pkg.insert_row(
           x_rowid     => l_rowid
         , x_report_code  => l_report_code
         , x_col1      => '10'
         , x_col2      => 'Think Customer'
         , x_col4      => '200'
         , x_col6      => '327'
         , x_col8      => '168'
         , x_col10     => '250'
         , x_col12     => '35.97'
      );

      jtfb_temp_report_pkg.insert_row(
           x_rowid     => l_rowid
         , x_report_code  => l_report_code
         , x_col1      => '20'
         , x_col2      => 'CRM in 90 Days'
         , x_col4      => '150'
         , x_col6      => '260'
         , x_col8      => '130'
         , x_col10     => '150'
         , x_col12     => '27.77'
      );

      jtfb_temp_report_pkg.insert_row(
           x_rowid     => l_rowid
         , x_report_code  => l_report_code
         , x_col1      => '30'
         , x_col2      => 'Interaction Center Push'
         , x_col4      => '400'
         , x_col6      => '345'
         , x_col8      => '140'
         , x_col10     => '365'
         , x_col12     => '41.24'
      );

   elsif (l_object = 'LEADS')
   then
      insert into jtfb_temp_report(report_code, col1, col2
            , col4, col6, col8, col10, col12)
         values(l_report_code, 'TOTAL', 'Total'
            , '466', '44','574','33','1117');
      insert into jtfb_temp_report(report_code, col1, col2
            , col4, col6, col8, col10, col12)
         values(l_report_code, '10', 'France'
            , '116','11','123','4','254');
      insert into jtfb_temp_report(report_code, col1, col2
            , col4, col6, col8, col10, col12)
         values(l_report_code, '20', 'Canada'
            , '120','10','151','6','287');
      insert into jtfb_temp_report(report_code, col1, col2
            , col4, col6, col8, col10, col12)
         values(l_report_code, '30', 'UK'
            , '90','8','140','8','246');
      insert into jtfb_temp_report(report_code, col1, col2
            , col4, col6, col8, col10, col12)
         values(l_report_code, '40', 'US'
            , '140','15','160','15','330');

   elsif (l_object = 'OPPORTUNITIES')
   then
      insert into jtfb_temp_report(report_code, col1, col2
            , col4, col6, col8, col10, col12)
         values(l_report_code, 'TOTAL', 'Total', '20'
            , '21','49','59','149');
      insert into jtfb_temp_report(report_code, col1, col2
            , col4, col6, col8, col10, col12)
         values(l_report_code, '10', 'US Defense'
            , '9','10','22','24','65');
      insert into jtfb_temp_report(report_code, col1, col2
            , col4, col6, col8, col10, col12)
         values(l_report_code, '20', 'Drainage Canal'
            , '5','3','12','14','34');
      insert into jtfb_temp_report(report_code, col1, col2
            , col4, col6, col8, col10, col12)
         values(l_report_code, '30', 'Water and Sanitary'
            , '6','8','15','21','50');

   elsif (l_object = 'QUOTES')
   then
      insert into jtfb_temp_report(report_code, col1, col2
            , col4, col6, col8, col10, col12)
         values(l_report_code, 'TOTAL', 'Total'
            , '42', '72','107','121','343');
      insert into jtfb_temp_report(report_code, col1, col2
            , col4, col6, col8, col10, col12)
         values(l_report_code, '10', 'Oracle Australia'
            , '15','20','40','43','118');
      insert into jtfb_temp_report(report_code, col1, col2
            , col4, col6, col8, col10, col12)
         values(l_report_code, '20', 'Oracle Argentina'
            , '5','10','12','16','43');
      insert into jtfb_temp_report(report_code, col1, col2
            , col4, col6, col8, col10, col12)
         values(l_report_code, '30', 'Oracle Canada'
            , '22','42','55','62','182');

   elsif (l_object = 'CUSTOMERS')
   then
      insert into jtfb_temp_report(report_code, col1, col2
            , col4, col6, col8, col10, col12)
         values(l_report_code, 'TOTAL', 'Total'
            ,  '448', '520','200','363','30.37');
      insert into jtfb_temp_report(report_code, col1, col2
            , col4, col6, col8, col10, col12)
         values(l_report_code, '10', 'Compaq'
            ,'50', '60','110','150','370');
      insert into jtfb_temp_report(report_code, col1, col2
            , col4, col6, col8, col10, col12)
         values(l_report_code, '20', 'Xerox'
            ,'70', '50','130','150','400');
      insert into jtfb_temp_report(report_code, col1, col2
            , col4, col6, col8, col10, col12)
         values(l_report_code, '30', 'GE Medical'
            ,'45', '80','140','240','505');
      insert into jtfb_temp_report(report_code, col1, col2
            , col4, col6, col8, col10, col12)
         values(l_report_code, '30', 'HP'
            ,'45', '80','140','140','405');
      insert into jtfb_temp_report(report_code, col1, col2
            , col4, col6, col8, col10, col12)
         values(l_report_code, '30', 'Papa Jones'
            ,'70', '80','140','280','570');

   else
      insert into jtfb_temp_report(report_code, col1, col2
            , col4, col6, col8, col10, col12)
         values(l_report_code, 'TOTAL', 'Total'
            , '514', '648','484','500','30.37');
      insert into jtfb_temp_report(report_code, col1, col2
            , col4, col6, col8, col10, col12)
         values(l_report_code, '10', 'Think Customer'
            , '200','327','168','250','35.97');
      insert into jtfb_temp_report(report_code, col1, col2
            , col4, col6, col8, col10, col12)
         values(l_report_code, '20', 'CRM in 90 Days'
            , '150','260','130','150','27.77');
      insert into jtfb_temp_report(report_code, col1, col2
            , col4, col6, col8, col10, col12)
         values(l_report_code, '30', 'Interaction Center Push'
            , '400','345','140','365','41.24');
   end if;

exception
   when others then
      write_message(l_method_name || sqlerrm);
end load_jtfb_demo_report;
--
--
function get_dynamic_footer(
   p_context in varchar2 default null
) return varchar2 is

   l_method_name  varchar2(80) := g_pkg_name || '.get_dynamic_footer: ';
   l_footer       varchar2(100) := 'Amount is scaled as: in Hundred Thousands';

begin

   return l_footer;

exception
   when others then
      write_message(l_method_name || sqlerrm);
end get_dynamic_footer;
--
--
function get_dynamic_name(
   p_context in varchar2 default null
) return varchar2 is

   l_method_name  varchar2(80) := g_pkg_name || '.get_dynamic_name: ';
   l_report_name  varchar2(100);

begin
   if (p_context = 'CAMPAIGNS')
   then
      l_report_name := 'Campaigns Lead Quality';

   elsif (p_context = 'LEADS')
   then
      l_report_name := 'Lead Activity Analysis';

   elsif (p_context = 'OPPORTUNITIES')
   then
      l_report_name := 'Opportunity Analysis';

   elsif (p_context = 'QUOTES')
   then
      l_report_name := 'Quote Analysis';

   elsif (p_context = 'CUSTOMERS')
   then
      l_report_name := 'Customer Analysis';

   elsif (p_context is null)
   then
      l_report_name := 'Activity Analysis';
   end if;

   return l_report_name;

exception
   when others then
      write_message(l_method_name || sqlerrm);
end get_dynamic_name;
--
--
function get_dynamic_report_col2(
   p_context in varchar2 default null
) return varchar2 is

   l_method_name  varchar2(80) := g_pkg_name || '.get_dynamic_report_col2: ';
   l_col_name     varchar2(100);

begin
   if (p_context = 'CAMPAIGNS')
   then
      l_col_name := 'Campaigns';

   elsif (p_context = 'LEADS')
   then
      l_col_name := 'Country';

   elsif (p_context = 'OPPORTUNITIES')
   then
      l_col_name := 'Organization Name';

   elsif (p_context = 'QUOTES')
   then
      l_col_name := 'Country Name';

   elsif (p_context = 'CUSTOMERS')
   then
      l_col_name := 'Customer Name';

   elsif (p_context is null)
   then
      l_col_name := 'Col Header2';
   end if;

   return l_col_name;

exception
   when others then
      write_message(l_method_name || sqlerrm);
end get_dynamic_report_col2;
--
--
function get_dynamic_report_col4(
   p_context in varchar2 default null
) return varchar2 is

   l_method_name  varchar2(80) := g_pkg_name || '.get_dynamic_report_col4: ';
   l_col_name     varchar2(100);

begin
   if (p_context = 'CAMPAIGNS')
   then
      l_col_name := 'Hot Leads';

   elsif (p_context = 'LEADS')
   then
      l_col_name := 'Prior Week';

   elsif (p_context = 'OPPORTUNITIES')
   then
      l_col_name := '01-05-2001';

   elsif (p_context = 'QUOTES')
   then
      l_col_name := '01-05-2001';

   elsif (p_context = 'CUSTOMERS')
   then
      l_col_name := 'Prior Week';

   elsif (p_context is null)
   then
      l_col_name := 'Col Header4';
   end if;

   return l_col_name;

exception
   when others then
      write_message(l_method_name || sqlerrm);
end get_dynamic_report_col4;
--
--
function get_dynamic_report_col6(
   p_context in varchar2 default null
) return varchar2 is

   l_method_name  varchar2(80) := g_pkg_name || '.get_dynamic_report_col6: ';
   l_col_name     varchar2(100);

begin
   if (p_context = 'CAMPAIGNS')
   then
      l_col_name := 'Medium Leads';

   elsif (p_context = 'LEADS')
   then
      l_col_name := 'Current Week';

   elsif (p_context = 'OPPORTUNITIES') then
      l_col_name := '02-05-2001';

   elsif (p_context = 'QUOTES')
   then
      l_col_name := '02-05-2001';

   elsif (p_context = 'CUSTOMERS')
   then
      l_col_name := 'Current Week';

   elsif (p_context is null)
   then
      l_col_name := 'Col Header6';
   end if;

   return l_col_name;

exception
   when others then
      write_message(l_method_name || sqlerrm);
end get_dynamic_report_col6;
--
--
function get_dynamic_report_col8(
   p_context in varchar2 default null
) return varchar2 is

   l_method_name  varchar2(80) := g_pkg_name || '.get_dynamic_report_col8: ';
   l_col_name     varchar2(100);

begin
   if (p_context = 'CAMPAIGNS')
   then
      l_col_name := 'Cold Leads';

   elsif (p_context = 'LEADS')
   then
      l_col_name := 'Prior Month';

   elsif (p_context = 'OPPORTUNITIES')
   then
      l_col_name := '03-05-2001';

   elsif (p_context = 'QUOTES')
   then
      l_col_name := '03-05-2001';

   elsif (p_context = 'CUSTOMERS')
   then
      l_col_name := 'Prior Month';

   elsif (p_context is null)
   then
      l_col_name := 'Col Header8';
   end if;

   return l_col_name;

exception
   when others then
      write_message(l_method_name || sqlerrm);
end get_dynamic_report_col8;
--
--
function get_dynamic_report_col10(
   p_context in varchar2 default null
) return varchar2 is

   l_method_name  varchar2(80) := g_pkg_name || '.get_dynamic_report_col10: ';
   l_col_name     varchar2(100);

begin
   if (p_context = 'CAMPAIGNS')
   then
      l_col_name := 'Unranked Leads';

   elsif (p_context = 'LEADS')
   then
      l_col_name := 'Current Month';

   elsif (p_context = 'OPPORTUNITIES')
   then
      l_col_name := '04-05-2001';

   elsif (p_context = 'QUOTES')
   then
      l_col_name := '04-05-2001';

   elsif (p_context = 'CUSTOMERS')
   then
      l_col_name := 'Current Month';

   elsif (p_context is null)
   then
      l_col_name := 'Col Header10';
   end if;

   return l_col_name;

exception
   when others then
      write_message(l_method_name || sqlerrm);
end get_dynamic_report_col10;
--
--
function get_dynamic_report_col12(
   p_context in varchar2 default null
) return varchar2 is

   l_method_name  varchar2(80) := g_pkg_name || '.get_dynamic_report_col12: ';
   l_col_name     varchar2(100);

begin
   if (p_context = 'CAMPAIGNS')
   then
      l_col_name := '% Ranked';

   elsif (p_context = 'LEADS')
   then
      l_col_name := 'Total';

   elsif (p_context = 'OPPORTUNITIES')
   then
      l_col_name := 'Total';

   elsif (p_context = 'QUOTES')
   then
      l_col_name := 'Total';

   elsif (p_context = 'CUSTOMERS')
   then
      l_col_name := 'Total';

   elsif (p_context is null)
   then
      l_col_name := 'Col Header12';
   end if;

   return l_col_name;

exception
   when others then
      write_message(l_method_name || sqlerrm);
end get_dynamic_report_col12;
--
--
function get_xaxis_label_name(
   p_context in varchar2 default null
) return varchar2 is

   l_method_name  varchar2(80) := g_pkg_name || '.get_xaxis_label_name: ';
   l_col_name     varchar2(100);

begin
   if (p_context = 'CAMPAIGNS')
   then
      l_col_name := 'Campaigns';

   elsif (p_context = 'LEADS')
   then
      l_col_name := 'Countries';

   elsif (p_context = 'OPPORTUNITIES')
   then
      l_col_name := 'Organizations';

   elsif (p_context = 'QUOTES')
   then
      l_col_name := 'Countries';

   elsif (p_context = 'CUSTOMERS')
   then
      l_col_name := 'Customers';

   elsif (p_context is null)
   then
      l_col_name := ' ';
   end if;

   return l_col_name;

exception
   when others then
      write_message(l_method_name || sqlerrm);
end get_xaxis_label_name;
--
--
function get_yaxis_label_name(
   p_context in varchar2 default null
) return varchar2 is

   l_method_name  varchar2(80) := g_pkg_name || '.get_yaxis_label_name: ';
   l_col_name     varchar2(100);

begin
   if (p_context = 'CAMPAIGNS')
   then
      l_col_name := 'Leads';

   elsif (p_context = 'LEADS')
   then
      l_col_name := 'Leads';

   elsif (p_context = 'OPPORTUNITIES')
   then
      l_col_name := 'Opportunities';

   elsif (p_context = 'QUOTES')
   then
      l_col_name := 'Quotes';

   elsif (p_context = 'CUSTOMERS')
   then
      l_col_name := 'Leads';

   elsif (p_context is null)
   then
      l_col_name := ' ';
   end if;

   return l_col_name;

exception
   when others then
      write_message(l_method_name || sqlerrm);
end get_yaxis_label_name;
--
--
end jtfb_picasso_demo;


/
