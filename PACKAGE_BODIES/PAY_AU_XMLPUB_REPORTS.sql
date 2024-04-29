--------------------------------------------------------
--  DDL for Package Body PAY_AU_XMLPUB_REPORTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_AU_XMLPUB_REPORTS" as
/* $Header: pyaurxml.pkb 120.1 2006/04/17 23:39:25 avenkatk noship $*/
/* ------------------------------------------------------------------------+
*** Program:     pay_au_xmlpub_reports (Package Body)
***
*** Change History
***
*** Date       Changed By  Version Bug No   Description of Change
*** ---------  ----------  ------- ------   --------------------------------+
***  7 Jul 05  avenkatk    1.0     3891577  Initial Version
***  9 Dec 05  avenkatk    1.1     4859876  Modified procedure submit_xml_reports
***                                         definition.
*** ------------------------------------------------------------------------+
*** R12 VERSIONS Change History
***
*** Date       Changed By  Version Bug No   Description of Change
*** ---------  ----------  ------- ------   --------------------------------+
*** 18 APR 06  avenkatk    12.1    4903621  Copy of Version 115.2, R12 Fix for
***                                         Bug 4859876
*** ------------------------------------------------------------------------+
*/
 g_debug boolean ;
 g_package                         constant varchar2(60) := 'pay_au_xmlpub_reports.';


procedure submit_xml_reports
( p_conc_request_id in number,
  p_template_type in varchar2,
  p_template_name in xdo_templates_b.template_code%type)
is
 l_procedure         varchar2(50);
 l_template_type  varchar2(50);
 l_prog_short_name varchar2(80);
 l_print_together       VARCHAR2(80);
 l_print_return         BOOLEAN;

 ps_request_id          NUMBER;

 cursor csr_get_print_options(c_request_id NUMBER) IS
 SELECT printer,
          print_style,
          decode(save_output_flag, 'Y', 'TRUE', 'N', 'FALSE') save_output
          ,number_of_copies
    FROM  fnd_concurrent_requests fcr
    WHERE fcr.request_id = c_request_id;

 rec_print_options  csr_get_print_options%ROWTYPE;

begin
g_debug := hr_utility.debug_enabled;

if g_debug then
  l_procedure := g_package||'submit_xml_reports';
  hr_utility.set_location('Inside procedure '||l_procedure,100);
end if;

       OPEN csr_get_print_options(p_conc_request_id);
       FETCH csr_get_print_options INTO rec_print_options;
       CLOSE csr_get_print_options;

       l_print_together := nvl(fnd_profile.value('CONC_PRINT_TOGETHER'), 'N');

       l_print_return :=  fnd_request.set_print_options
                           (printer        => rec_print_options.printer,
                            style          => rec_print_options.print_style,
                            copies         => rec_print_options.number_of_copies,
                            save_output    => hr_general.char_to_bool(rec_print_options.save_output),
                            print_together => l_print_together);

/* Based on the template type identify the Concurrent program to be
   submitted */

     if (p_template_type = 'EXC')
     then
       l_prog_short_name := 'PYAUREXC';
     else
       l_prog_short_name := 'PYAURPDF';
     end if;

      if g_debug then
        hr_utility.set_location('Concurrent Program submitted '||l_prog_short_name,120);
      end if;

/* Bug 4903621
    Java Concurrent Programs(PDF and Excel) take the following parameters
    1. P_PROGRAM_NAME    (Report Name)
    2. P_VALID_DATA_CODE (Data Definition Code)
    3. P_REQUEST_DATE    (Request Date)
    4. P_REQUEST_ID      (Request ID with Concurrent XML output)
    5. P_OUTPUT_TYPE     (Output Type - PDF/EXC )
    6. P_TEMPLATE_NAME   (Template Code)
    7. P_DEBUG_FLAG      (Debug Flag Y/N)

   JCP submitted internally requires Request ID, Output Type, Template Name and Debug Flag. Rest
   of the parameters will be set as NULL.
*/


ps_request_id := fnd_request.submit_request
 ('PAY',
  l_prog_short_name,
   null,
   null,
   false,
   NULL,                       -- P_PROGRAM_NAME
   NULL,                       -- P_VALID_DATA_CODE
   NULL,                       -- P_REQUEST_DATE
   to_char(p_conc_request_id), -- P_REQUEST ID
   p_template_type,            -- P_OUTPUT_TYPE
   p_template_name,            -- P_TEMPLATE_NAME
   'N',                        -- P_DEBUG_FLAG
   'BLANKPAGES=NO',
   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,
   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,
   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,
   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,
   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,
   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,
   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,
   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,
   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,
   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,
   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,
   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,
   NULL,   NULL,   NULL,   NULL
);
      if g_debug then
        hr_utility.set_location('Leaving procedure '||l_procedure,140);
      end if;

end submit_xml_reports;


function get_request_details
(p_conc_request_id in number)
return varchar2
is
l_count number;
l_procedure         varchar2(50);

cursor get_argument_values(p_conc_request_id fnd_concurrent_requests.request_id%type)
is
  select
    p.srs_flag, p.concurrent_program_name, r.program_application_id,
    r.argument1, r.argument2, r.argument3, r.argument4,
    r.argument5, r.argument6, r.argument7, r.argument8,
    r.argument9, r.argument10, r.argument11, r.argument12,
    r.argument13, r.argument14, r.argument15, r.argument16,
    r.argument17, r.argument18, r.argument19, r.argument20,
    r.argument21, r.argument22, r.argument23, r.argument24,
    r.argument25,  r.number_of_arguments,r.request_date
  from fnd_concurrent_requests r, fnd_concurrent_programs p
  where r.request_id = p_conc_request_id
  and r.concurrent_program_id = p.concurrent_program_id
  and r.program_application_id = p.application_id;

cursor get_all_arguments(p_conc_request_id fnd_concurrent_requests.request_id%type)
is
    select
    Argument26, Argument27, Argument28, Argument29, Argument30,
    Argument31, Argument32, Argument33, Argument34, Argument35,
    Argument36, Argument37, Argument38, Argument39, Argument40,
    Argument41, Argument42, Argument43, Argument44, Argument45,
    Argument46, Argument47, Argument48, Argument49, Argument50,
    Argument51, Argument52, Argument53, Argument54, Argument55,
    Argument56, Argument57, Argument58, Argument59, Argument60,
    Argument61, Argument62, Argument63, Argument64, Argument65,
    Argument66, Argument67, Argument68, Argument69, Argument70,
    Argument71, Argument72, Argument73, Argument74, Argument75,
    Argument76, Argument77, Argument78, Argument79, Argument80,
    Argument81, Argument82, Argument83, Argument84, Argument85,
    Argument86, Argument87, Argument88, Argument89, Argument90,
    Argument91, Argument92, Argument93, Argument94, Argument95,
    Argument96, Argument97, Argument98, Argument99, Argument100
    from fnd_conc_request_arguments
 where request_id = p_conc_request_id;


cursor get_attribute_order(l_appl_id fnd_concurrent_programs.application_id%type
                          ,l_conc_prog_name fnd_concurrent_programs.concurrent_program_name%type)
is
 select to_number(substr(application_column_name, 10)) num,
        end_user_column_name
    from fnd_descr_flex_column_usages
   where application_id = l_appl_id
     and descriptive_flexfield_name = '$SRS$.'||l_conc_prog_name
     and descriptive_flex_context_code = 'Global Data Elements'
     and enabled_flag = 'Y'
   order by column_seq_num;

l_attribute_row get_attribute_order%ROWTYPE;

l_return varchar2(300);
l_found boolean;

TYPE char_tab_type is TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;
l_argument_row char_tab_type;

l_srs_flag           fnd_concurrent_programs.srs_flag%type;
l_conc_program_name  fnd_concurrent_programs.concurrent_program_name%type;
l_prog_appl_id       fnd_concurrent_requests.program_application_id%type;
l_number_of_arg      fnd_concurrent_requests.number_of_arguments%type;
l_request_date       fnd_concurrent_requests.request_date%type;


begin

g_debug := hr_utility.debug_enabled;

if g_debug then
  l_procedure := g_package||'get_request_details';
  hr_utility.set_location('Inside Function '||l_procedure,100);
end if;

open get_argument_values(p_conc_request_id);
fetch get_argument_values
       into l_srs_flag,l_conc_program_name,l_prog_appl_id,
            l_argument_row(1), l_argument_row(2), l_argument_row(3), l_argument_row(4),
            l_argument_row(5), l_argument_row(6), l_argument_row(7), l_argument_row(8),
            l_argument_row(9), l_argument_row(10), l_argument_row(11), l_argument_row(12),
            l_argument_row(13), l_argument_row(14), l_argument_row(15), l_argument_row(16),
            l_argument_row(17), l_argument_row(18), l_argument_row(19), l_argument_row(20),
            l_argument_row(21), l_argument_row(22), l_argument_row(23), l_argument_row(24),
            l_argument_row(25),l_number_of_arg,l_request_date;
close get_argument_values;

l_count := 0;
l_found := false;

FOR csr_rec IN  get_attribute_order(l_prog_appl_id
                                   ,l_conc_program_name)
LOOP
if (l_found = false)
then
    l_count := l_count + 1;
    if csr_rec.end_user_column_name = 'P_REQUEST_DETAILS'
    then
       l_found := true;
    end if;
end if;
END LOOP;

if g_debug then
    hr_utility.trace('l_count            '||l_count);
end if;

if l_found = true then
    if l_count <= 25 then
        l_return := 'Submitted on '||to_char(l_request_date,'DD-MON-YYYY ')
                     ||l_argument_row(l_count);
    else

        open get_all_arguments(p_conc_request_id);
        fetch get_all_arguments into
        l_argument_row(26), l_argument_row(27), l_argument_row(28), l_argument_row(29), l_argument_row(30),
        l_argument_row(31), l_argument_row(32), l_argument_row(33), l_argument_row(34), l_argument_row(35),
        l_argument_row(36), l_argument_row(37), l_argument_row(38), l_argument_row(39), l_argument_row(40),
        l_argument_row(41), l_argument_row(42), l_argument_row(43), l_argument_row(44), l_argument_row(45),
        l_argument_row(46), l_argument_row(47), l_argument_row(48), l_argument_row(49), l_argument_row(50),
        l_argument_row(51), l_argument_row(52), l_argument_row(53), l_argument_row(54), l_argument_row(55),
        l_argument_row(56), l_argument_row(57), l_argument_row(58), l_argument_row(59), l_argument_row(60),
        l_argument_row(61), l_argument_row(62), l_argument_row(63), l_argument_row(64), l_argument_row(65),
        l_argument_row(66), l_argument_row(67), l_argument_row(68), l_argument_row(69), l_argument_row(70),
        l_argument_row(71), l_argument_row(72), l_argument_row(73), l_argument_row(74), l_argument_row(75),
        l_argument_row(76), l_argument_row(77), l_argument_row(78), l_argument_row(79), l_argument_row(80),
        l_argument_row(81), l_argument_row(82), l_argument_row(83), l_argument_row(84), l_argument_row(85),
        l_argument_row(86), l_argument_row(87), l_argument_row(88), l_argument_row(89), l_argument_row(90),
        l_argument_row(91), l_argument_row(92), l_argument_row(93), l_argument_row(94), l_argument_row(95),
        l_argument_row(96), l_argument_row(97), l_argument_row(98), l_argument_row(99), l_argument_row(100);
       close get_all_arguments;

    l_return := 'Submitted on '||to_char(l_request_date,'DD-MON-YYYY ')
                ||l_argument_row(l_count);
    end if;
end if;

if g_debug then
    hr_utility.trace('Return String '||l_return);
end if;

return substr(l_return,1,240);

end get_request_details;


end pay_au_xmlpub_reports;

/
