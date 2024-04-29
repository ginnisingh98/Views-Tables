--------------------------------------------------------
--  DDL for Package Body IGIRX_C_IAC_PROJ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGIRX_C_IAC_PROJ" AS
/* $Header: igiiapxb.pls 120.6 2007/08/01 10:44:48 npandya ship $ */

--===========================FND_LOG.START=====================================

g_state_level NUMBER	     :=	FND_LOG.LEVEL_STATEMENT;
g_proc_level  NUMBER	     :=	FND_LOG.LEVEL_PROCEDURE;
g_event_level NUMBER	     :=	FND_LOG.LEVEL_EVENT;
g_excep_level NUMBER	     :=	FND_LOG.LEVEL_EXCEPTION;
g_error_level NUMBER	     :=	FND_LOG.LEVEL_ERROR;
g_unexp_level NUMBER	     :=	FND_LOG.LEVEL_UNEXPECTED;
g_path        VARCHAR2(100)  := 'IGI.PLSQL.igiiapxb.igirx_c_iac_proj.';

--===========================FND_LOG.END=======================================

-- ====================================================================
-- PROCEDURE proj:
-- ====================================================================

PROCEDURE proj (
  errbuf	    out nocopy varchar2,
  retcode	    out nocopy varchar2,
  argument1	    in	varchar2,   -- projection_id
  argument2         in  varchar2  default  null,
  argument3         in  varchar2  default  null,
  argument4         in  varchar2  default  null,
  argument5         in  varchar2  default  null,
  argument6         in  varchar2  default  null,
  argument7         in  varchar2  default  null,
  argument8         in  varchar2  default  null,
  argument9         in  varchar2  default  null,
  argument10        in  varchar2  default  null,
  argument11	   in  varchar2  default  null,
  argument12        in  varchar2  default  null,
  argument13        in  varchar2  default  null,
  argument14        in  varchar2  default  null,
  argument15        in  varchar2  default  null,
  argument16        in  varchar2  default  null,
  argument17        in  varchar2  default  null,
  argument18        in  varchar2  default  null,
  argument19        in  varchar2  default  null,
  argument20        in  varchar2  default  null,
  argument21	   in  varchar2  default  null,
  argument22        in  varchar2  default  null,
  argument23        in  varchar2  default  null,
  argument24        in  varchar2  default  null,
  argument25        in  varchar2  default  null,
  argument26        in  varchar2  default  null,
  argument27        in  varchar2  default  null,
  argument28        in  varchar2  default  null,
  argument29        in  varchar2  default  null,
  argument30        in  varchar2  default  null,
  argument31	   in  varchar2  default  null,
  argument32        in  varchar2  default  null,
  argument33        in  varchar2  default  null,
  argument34        in  varchar2  default  null,
  argument35        in  varchar2  default  null,
  argument36        in  varchar2  default  null,
  argument37        in  varchar2  default  null,
  argument38        in  varchar2  default  null,
  argument39        in  varchar2  default  null,
  argument40        in  varchar2  default  null,
  argument41	   in  varchar2  default  null,
  argument42        in  varchar2  default  null,
  argument43        in  varchar2  default  null,
  argument44        in  varchar2  default  null,
  argument45        in  varchar2  default  null,
  argument46        in  varchar2  default  null,
  argument47        in  varchar2  default  null,
  argument48        in  varchar2  default  null,
  argument49        in  varchar2  default  null,
  argument50        in  varchar2  default  null,
  argument51	   in  varchar2  default  null,
  argument52        in  varchar2  default  null,
  argument53        in  varchar2  default  null,
  argument54        in  varchar2  default  null,
  argument55        in  varchar2  default  null,
  argument56        in  varchar2  default  null,
  argument57        in  varchar2  default  null,
  argument58        in  varchar2  default  null,
  argument59        in  varchar2  default  null,
  argument60        in  varchar2  default  null,
  argument61	   in  varchar2  default  null,
  argument62        in  varchar2  default  null,
  argument63        in  varchar2  default  null,
  argument64        in  varchar2  default  null,
  argument65        in  varchar2  default  null,
  argument66        in  varchar2  default  null,
  argument67        in  varchar2  default  null,
  argument68        in  varchar2  default  null,
  argument69        in  varchar2  default  null,
  argument70        in  varchar2  default  null,
  argument71	   in  varchar2  default  null,
  argument72        in  varchar2  default  null,
  argument73        in  varchar2  default  null,
  argument74        in  varchar2  default  null,
  argument75        in  varchar2  default  null,
  argument76        in  varchar2  default  null,
  argument77        in  varchar2  default  null,
  argument78        in  varchar2  default  null,
  argument79        in  varchar2  default  null,
  argument80        in  varchar2  default  null,
  argument81	   in  varchar2  default  null,
  argument82        in  varchar2  default  null,
  argument83        in  varchar2  default  null,
  argument84        in  varchar2  default  null,
  argument85        in  varchar2  default  null,
  argument86        in  varchar2  default  null,
  argument87        in  varchar2  default  null,
  argument88        in  varchar2  default  null,
  argument89        in  varchar2  default  null,
  argument90        in  varchar2  default  null,
  argument91	   in  varchar2  default  null,
  argument92        in  varchar2  default  null,
  argument93        in  varchar2  default  null,
  argument94        in  varchar2  default  null,
  argument95        in  varchar2  default  null,
  argument96        in  varchar2  default  null,
  argument97        in  varchar2  default  null,
  argument98        in  varchar2  default  null,
  argument99        in  varchar2  default  null,
  argument100            in       varchar2 default null) is

  h_request_id    NUMBER := fnd_global.conc_request_id;
  l_path 	  VARCHAR2(100) := g_path||'proj';
  BEGIN

   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'projection id:   '||argument1);

   h_request_id := fnd_global.conc_request_id;

   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Before calling inner procedure, request id: '||h_request_id);
   igirx_iac_proj.proj(
        p_projection_id => to_number(argument1),
        p_request_id 	=> h_request_id,
	retcode 	=> retcode,
	errbuf 		=> errbuf);

   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Projections Outer wrapper completed success fully');
   retcode := 0;
   errbuf := 'Successful!';

  EXCEPTION
     WHEN OTHERS THEN
          retcode := 2;
	  FND_MESSAGE.SET_NAME('IGI', 'IGI_IAC_EXCEPTION');
	      FND_MESSAGE.SET_TOKEN('PACKAGE','igirx_c_iac_proj');
	      FND_MESSAGE.SET_TOKEN('ERROR_MESSAGE','Projections Outer wrapper Unsuccessful!');

          errbuf := fnd_message.get ;
	  igi_iac_debug_pkg.debug_unexpected_msg(l_path);
  END proj;

END igirx_c_iac_proj;

/
