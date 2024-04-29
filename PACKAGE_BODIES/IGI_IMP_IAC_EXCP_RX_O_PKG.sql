--------------------------------------------------------
--  DDL for Package Body IGI_IMP_IAC_EXCP_RX_O_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IMP_IAC_EXCP_RX_O_PKG" AS
-- $Header: igiiaeob.pls 120.5.12000000.1 2007/08/01 16:15:07 npandya noship $


--===========================FND_LOG.START=====================================

g_state_level NUMBER	     :=	FND_LOG.LEVEL_STATEMENT;
g_proc_level  NUMBER	     :=	FND_LOG.LEVEL_PROCEDURE;
g_event_level NUMBER	     :=	FND_LOG.LEVEL_EVENT;
g_excep_level NUMBER	     :=	FND_LOG.LEVEL_EXCEPTION;
g_error_level NUMBER	     :=	FND_LOG.LEVEL_ERROR;
g_unexp_level NUMBER	     :=	FND_LOG.LEVEL_UNEXPECTED;
g_path        VARCHAR2(100)  := 'IGI.PLSQL.igiiaeob.IGI_IMP_IAC_EXCP_RX_O_PKG.';

--===========================FND_LOG.END=====================================

  PROCEDURE start_rx_process (
		errbuf	    OUT NOCOPY VARCHAR2,
		retcode	    OUT NOCOPY VARCHAR2,
		argument1         IN  VARCHAR2,   --  Book Type Code
		argument2         IN  VARCHAR2,   --  Period Counter
		argument3         IN  VARCHAR2     DEFAULT  NULL,
		argument4         IN  VARCHAR2   DEFAULT  NULL,
		argument5         IN  VARCHAR2   DEFAULT  NULL,
		argument6         IN  VARCHAR2  DEFAULT  NULL,
		argument7         IN  VARCHAR2  DEFAULT  NULL,
		argument8         IN  VARCHAR2  DEFAULT  NULL,
		argument9         IN  VARCHAR2  DEFAULT  NULL,
		argument10        IN  VARCHAR2  DEFAULT  NULL,
		argument11        IN  VARCHAR2  DEFAULT  NULL,
		argument12        IN  VARCHAR2  DEFAULT  NULL,
		argument13        IN  VARCHAR2  DEFAULT  NULL,
		argument14        IN  VARCHAR2  DEFAULT  NULL,
		argument15        IN  VARCHAR2  DEFAULT  NULL,
		argument16        IN  VARCHAR2  DEFAULT  NULL,
		argument17        IN  VARCHAR2  DEFAULT  NULL,
		argument18        IN  VARCHAR2  DEFAULT  NULL,
		argument19        IN  VARCHAR2  DEFAULT  NULL,
		argument20        IN  VARCHAR2  DEFAULT  NULL,
		argument21	      IN  VARCHAR2  DEFAULT  NULL,
		argument22        IN  VARCHAR2  DEFAULT  NULL,
		argument23        IN  VARCHAR2  DEFAULT  NULL,
		argument24        IN  VARCHAR2  DEFAULT  NULL,
		argument25        IN  VARCHAR2  DEFAULT  NULL,
		argument26        IN  VARCHAR2  DEFAULT  NULL,
		argument27        IN  VARCHAR2  DEFAULT  NULL,
		argument28        IN  VARCHAR2  DEFAULT  NULL,
		argument29        IN  VARCHAR2  DEFAULT  NULL,
		argument30        IN  VARCHAR2  DEFAULT  NULL,
		argument31	      IN  VARCHAR2  DEFAULT  NULL,
		argument32        IN  VARCHAR2  DEFAULT  NULL,
		argument33        IN  VARCHAR2  DEFAULT  NULL,
		argument34        IN  VARCHAR2  DEFAULT  NULL,
		argument35        IN  VARCHAR2  DEFAULT  NULL,
		argument36        IN  VARCHAR2  DEFAULT  NULL,
		argument37        IN  VARCHAR2  DEFAULT  NULL,
		argument38        IN  VARCHAR2  DEFAULT  NULL,
		argument39        IN  VARCHAR2  DEFAULT  NULL,
		argument40        IN  VARCHAR2  DEFAULT  NULL,
		argument41	      IN  VARCHAR2  DEFAULT  NULL,
		argument42        IN  VARCHAR2  DEFAULT  NULL,
		argument43        IN  VARCHAR2  DEFAULT  NULL,
		argument44        IN  VARCHAR2  DEFAULT  NULL,
		argument45        IN  VARCHAR2  DEFAULT  NULL,
		argument46        IN  VARCHAR2  DEFAULT  NULL,
		argument47        IN  VARCHAR2  DEFAULT  NULL,
		argument48        IN  VARCHAR2  DEFAULT  NULL,
		argument49        IN  VARCHAR2  DEFAULT  NULL,
		argument50        IN  VARCHAR2  DEFAULT  NULL,
		argument51	      IN  VARCHAR2  DEFAULT  NULL,
		argument52        IN  VARCHAR2  DEFAULT  NULL,
		argument53        IN  VARCHAR2  DEFAULT  NULL,
		argument54        IN  VARCHAR2  DEFAULT  NULL,
		argument55        IN  VARCHAR2  DEFAULT  NULL,
		argument56        IN  VARCHAR2  DEFAULT  NULL,
		argument57        IN  VARCHAR2  DEFAULT  NULL,
		argument58        IN  VARCHAR2  DEFAULT  NULL,
		argument59        IN  VARCHAR2  DEFAULT  NULL,
		argument60        IN  VARCHAR2  DEFAULT  NULL,
		argument61	      IN  VARCHAR2  DEFAULT  NULL,
		argument62        IN  VARCHAR2  DEFAULT  NULL,
		argument63        IN  VARCHAR2  DEFAULT  NULL,
		argument64        IN  VARCHAR2  DEFAULT  NULL,
		argument65        IN  VARCHAR2  DEFAULT  NULL,
		argument66        IN  VARCHAR2  DEFAULT  NULL,
		argument67        IN  VARCHAR2  DEFAULT  NULL,
		argument68        IN  VARCHAR2  DEFAULT  NULL,
		argument69        IN  VARCHAR2  DEFAULT  NULL,
		argument70        IN  VARCHAR2  DEFAULT  NULL,
		argument71	      IN  VARCHAR2  DEFAULT  NULL,
		argument72        IN  VARCHAR2  DEFAULT  NULL,
		argument73        IN  VARCHAR2  DEFAULT  NULL,
		argument74        IN  VARCHAR2  DEFAULT  NULL,
		argument75        IN  VARCHAR2  DEFAULT  NULL,
		argument76        IN  VARCHAR2  DEFAULT  NULL,
		argument77        IN  VARCHAR2  DEFAULT  NULL,
		argument78        IN  VARCHAR2  DEFAULT  NULL,
		argument79        IN  VARCHAR2  DEFAULT  NULL,
		argument80        IN  VARCHAR2  DEFAULT  NULL,
		argument81	      IN  VARCHAR2  DEFAULT  NULL,
		argument82        IN  VARCHAR2  DEFAULT  NULL,
		argument83        IN  VARCHAR2  DEFAULT  NULL,
		argument84        IN  VARCHAR2  DEFAULT  NULL,
		argument85        IN  VARCHAR2  DEFAULT  NULL,
		argument86        IN  VARCHAR2  DEFAULT  NULL,
		argument87        IN  VARCHAR2  DEFAULT  NULL,
		argument88        IN  VARCHAR2  DEFAULT  NULL,
		argument89        IN  VARCHAR2  DEFAULT  NULL,
		argument90        IN  VARCHAR2  DEFAULT  NULL,
		argument91	      IN  VARCHAR2  DEFAULT  NULL,
		argument92        IN  VARCHAR2  DEFAULT  NULL,
		argument93        IN  VARCHAR2  DEFAULT  NULL,
		argument94        IN  VARCHAR2  DEFAULT  NULL,
		argument95        IN  VARCHAR2  DEFAULT  NULL,
		argument96        IN  VARCHAR2  DEFAULT  NULL,
		argument97        IN  VARCHAR2  DEFAULT  NULL,
		argument98        IN  VARCHAR2  DEFAULT  NULL,
		argument99        IN  VARCHAR2  DEFAULT  NULL,
		argument100       IN  VARCHAR2 DEFAULT NULL) IS

  l_request_id    NUMBER;
  h_err_msg     VARCHAR2(2000);

  l_path varchar2(100) := g_path||'start_rx_process';

  BEGIN

    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Have reached outer package');

    l_request_id := fnd_global.conc_request_id;
    retcode := 2;
    igi_imp_iac_excep_iner_pkg.run_report
		 ( p_book		=>	argument1,
           p_period		=>	argument2,
           p_request_id		=>	l_request_id,
		   p_retcode		=>	retcode,
		   p_errbuf		=>	errbuf);

    retcode := 0;


  EXCEPTION WHEN OTHERS THEN
      igi_iac_debug_pkg.debug_other_string(g_unexp_level,l_path,'Exception in start_rx_process : '|| sqlerrm);
      retcode := 2;
  END start_rx_process;

END IGI_IMP_IAC_EXCP_RX_O_PKG;

/
