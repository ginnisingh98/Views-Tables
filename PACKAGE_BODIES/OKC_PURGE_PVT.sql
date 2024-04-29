--------------------------------------------------------
--  DDL for Package Body OKC_PURGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_PURGE_PVT" AS
/* $Header: OKCVPURB.pls 120.0 2005/05/25 18:21:08 appldev noship $ */

/*
-- PROCEDURE purge
-- Called by concurrent program to purge old data.
-- Parameter p_num_days is how far in the past to end the purge
-- 	     p_purge_type is a lookup_code based on lookup_type OKC_PURGE_TYPE
-- 			  indicating what kind of purge
*/
 PROCEDURE purge (
    errbuf  OUT NOCOPY VARCHAR2,
    retcode OUT NOCOPY VARCHAR2,
    p_purge_type IN VARCHAR2,
    p_num_days IN NUMBER default 3)
IS
    l_api_name VARCHAR2(50) := 'purge';
    E_Resource_Busy   EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy,  -00054);
BEGIN
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,l_api_name,'100: Inside OKC_PURGE_PVT.PURGE');
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,l_api_name,'Parameters:  p_num_days='||p_num_days||'   p_purge_type='||p_purge_type);
   END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG,'Parameters:  p_num_days='||p_num_days||'   p_purge_type='||p_purge_type);

    --Initialize the return code
   retcode := 0;

   -- Added elsif part to call purge_deviations_data if the
   -- parameter passed is OKC_DEV_REPORT_T

   if p_purge_type = 'OKC_QA_ERRORS_T' then
	okc_terms_util_pvt.purge_qa_results(errbuf=>errbuf,
			 	            retcode=>retcode,
			                    p_num_days=>p_num_days);
   elsif p_purge_type = 'OKC_DEV_REPORT_T' Then
   	okc_terms_deviations_pvt.purge_deviations_data(errbuf=>errbuf,
							retcode=>retcode,
							p_num_days=>p_num_days);
    ELSIF p_purge_type = 'OKC_REP_RECENT_T' THEN
      OKC_REP_UTIL_PVT.purge_recent_contracts(
   	    errbuf=>errbuf,
			  retcode=>retcode,
			  p_num_days=>p_num_days);
   end if;

   commit;

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,l_api_name,'100: leaving OKC_TERMS_UTIL_PVT.PURGE');
   END IF;


   EXCEPTION
    WHEN E_Resource_Busy THEN

        IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        	  FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,l_api_name,'200: Resource busy exception');
   	END IF;

      IF FND_MSG_PUB.Count_Msg > 0 Then
        FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
          FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MSG_PUB.Get(i,p_encoded =>FND_API.G_FALSE ));
        END LOOP;
      END IF;
      FND_MSG_PUB.initialize;
      RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    WHEN OTHERS THEN

      retcode := 2;
      errbuf  := substr(sqlerrm,1,200);

        IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        	  FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,l_api_name,'200: Other exception:'||errbuf);
   	END IF;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
      END IF;
      IF FND_MSG_PUB.Count_Msg > 0 Then
        FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
          FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MSG_PUB.Get(i,p_encoded =>FND_API.G_FALSE ));
        END LOOP;
      END IF;
      FND_MSG_PUB.initialize;


END purge;


END OKC_PURGE_PVT;

/
