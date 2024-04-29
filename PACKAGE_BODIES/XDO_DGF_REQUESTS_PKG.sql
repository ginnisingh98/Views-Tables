--------------------------------------------------------
--  DDL for Package Body XDO_DGF_REQUESTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDO_DGF_REQUESTS_PKG" as
/* $Header: XDODGFRQB.pls 120.0 2008/01/19 00:14:00 bgkim noship $ */

   g_current_runtime_level           NUMBER  := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   g_level_statement       CONSTANT  NUMBER  := FND_LOG.LEVEL_STATEMENT;
   g_level_procedure       CONSTANT  NUMBER  := FND_LOG.LEVEL_PROCEDURE;
   g_level_event           CONSTANT  NUMBER  := FND_LOG.LEVEL_EVENT;
   g_level_unexpected      CONSTANT  NUMBER  := FND_LOG.LEVEL_UNEXPECTED;
   g_error_buffer                    VARCHAR2(100);

   submit_failed exception;

   FUNCTION submit_request
     ( application IN varchar2,
       program     IN varchar2,
       params      IN request_parameters_table
       )
   RETURN  number
   IS
   	l_request_id  number;
	l_wait_status boolean;

	l_phase       varchar2(1000);
	l_status      varchar2(1000);
	l_dev_phase   varchar2(1000);
	l_dev_status  varchar2(1000);
	l_message     varchar2(1000);
	l_log_message varchar2(1000);

   begin
    l_request_id := FND_REQUEST.SUBMIT_REQUEST(
               application,
               program,
               '',
               '',
               FALSE,
               params(1),params(2),params(3),params(4),params(5),
               params(6),params(7),params(8),params(9),
               params(10),params(11),params(12),params(13),params(14),params(15),
               params(16),params(17),params(18),params(19),params(20),params(21),
               params(22),params(23),params(24),params(25),params(26),params(27),
               params(28),params(29),params(30),params(31),params(32),params(33),
               params(34),params(35),params(36),params(37),params(38),params(39),
               params(40),params(41),params(42),params(43),params(44),params(45),
               params(46),params(47),params(48),params(49),params(50),params(51),
               params(52),params(53),params(54),params(55),params(56),params(57),
               params(58),params(59),params(60),params(61),params(62),params(63),
               params(64),params(65),params(66),params(67),params(68),params(69),
               params(70),params(71),params(72),params(73),params(74),params(75),
               params(76),params(77),params(78),params(79),params(80),params(81),
               params(82),params(83),params(84),params(85),params(86),params(87),
               params(88),params(89),params(90),params(91),params(92),params(93),
               params(94),params(95),params(96),params(97),params(98),params(99),
               params(100));

     l_log_message := ';l_request_id='||l_request_id;

     commit;

     l_wait_status :=  fnd_concurrent.wait_for_request( l_request_id,
		  					1,
		  					180,
		  					l_phase      ,
		  					l_status     ,
		  					l_dev_phase  ,
		  					l_dev_status ,
		  					l_message);

	   if l_wait_status
	   then
	   	  l_log_message := l_log_message || ';l_wait_status='||'TRUE';
	   else
	   	  l_log_message := l_log_message || ';l_wait_status='||'FALSE';
	   end if;

	   l_log_message := l_log_message || ';l_phase'||l_phase;
	   l_log_message := l_log_message || ';l_status'||l_status;
	   l_log_message := l_log_message || ';l_dev_phase'||l_dev_phase;
	   l_log_message := l_log_message || ';l_dev_status'||l_dev_status;
	   l_log_message := l_log_message || ';l_message'||l_message;


     return l_request_id;
   end;

   FUNCTION submit_request(p_report_code        in varchar2,
                           p_all_parameter_list XDO_DGF_RPT_PKG.PARAM_TABLE_TYPE)
   RETURN number
   is
    l_request_id             number;
    j                        integer := 0;
    l_request_params         request_parameters_table;
    l_report_code            varchar2(40);
    l_report_appl_short_name varchar2(15);
    l_separator_pos          integer;
   begin

     IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'xdo_dgf_request_pkg.submit_request',
                      'start');
     END IF;

    -- init l_request_params
    for k in 1..100
    loop
      l_request_params(k) := '';
    end loop;

    -- find parameters for the selected report
    for i in 1..p_all_parameter_list.count
    loop
 	 if p_all_parameter_list(i).report_code = p_report_code
 	 then
 	   j := j + 1;
 	   l_request_params(j) := p_all_parameter_list(i).parameter_value;
 	 end if;
    end loop;

    -- get report code and report application short name
    l_separator_pos := instr(p_report_code,':');
    l_report_code := substr(p_report_code, l_separator_pos + 1);
    l_report_appl_short_name := substr(p_report_code, 1, l_separator_pos - 1);

    -- run the selected report
    l_request_id := xdo_dgf_requests_pkg.submit_request(l_report_appl_short_name,l_report_code, l_request_params);
    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'xdo_dgf_request_pkg.submit_request',
                     'end: l_request_id = ' || l_request_id);
     END IF;

    return l_request_id;
   end;

   FUNCTION submit_request(p_report_code        IN varchar2,
                           p_all_parameter_list XDO_DGF_PARAM_TABLE_TYPE)
   RETURN number
   is
    l_request_id number;
    j integer := 0;
    l_request_params request_parameters_table;
    l_report_code varchar2(40);
	l_report_appl_short_name varchar2(15);
	l_separator_pos integer;
   begin
     IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'xdo_dgf_request_pkg.submit_request',
                     'start');
     END IF;

    -- init l_request_params
    for k in 1..100
    loop
      l_request_params(k) := '';
    end loop;

    -- find parameters for the selected report
    for i in 1..p_all_parameter_list.count
    loop
 	 if p_all_parameter_list(i).report_code = p_report_code
 	 then
 	   j := j + 1;
 	   l_request_params(j) := p_all_parameter_list(i).parameter_value;
 	 end if;
    end loop;

    -- get report code and report application short name
    l_separator_pos          := instr(p_report_code,':');
    l_report_code            := substr(p_report_code, l_separator_pos + 1);
    l_report_appl_short_name := substr(p_report_code, 1, l_separator_pos - 1);

    -- run the selected report
    l_request_id := xdo_dgf_requests_pkg.submit_request(l_report_appl_short_name,l_report_code, l_request_params);

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'xdo_dgf_request_pkg.submit_request',
                     'end: l_request_id = ' || l_request_id);
    END IF;
    return l_request_id;
   end;



      FUNCTION submit_request
     ( application IN varchar2,
       program     IN varchar2,
       param1      IN varchar2,
       param2      IN varchar2
       )
     RETURN  number
     is
       params request_parameters_table;
     begin
       params(1) := param1;
       params(2) := param2;
       params(3) := '';
       params(4) := '';
       params(5) := '';
       params(6) := '';
       params(7) := '';
       params(8) := '';
       params(9) := '';
       params(10) := '';

       return submit_request(application,program,params);
     end;

END xdo_dgf_requests_pkg;

/
