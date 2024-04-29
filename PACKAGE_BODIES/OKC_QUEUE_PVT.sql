--------------------------------------------------------
--  DDL for Package Body OKC_QUEUE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_QUEUE_PVT" as
-- $Header: OKCRQUEB.pls 120.0 2005/05/25 18:15:30 appldev noship $

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
  l_schema   varchar2(30);
  l_status   varchar2(1);
  l_industry varchar2(1);

-- this function is used to to resove rule based subscription
FUNCTION get_acn_type (p_corrid  IN  VARCHAR2)
RETURN VARCHAR2
IS
CURSOR acn_cur
IS
SELECT acn_type
FROM okc_actions_b
WHERE correlation = p_corrid;
acn_rec  acn_cur%ROWTYPE;
v_acn_type  okc_actions_b.acn_type%TYPE;

BEGIN
    OPEN acn_cur;
    FETCH acn_cur INTO acn_rec;
       IF acn_cur%NOTFOUND THEN
         RETURN('Not Available');
       ELSE
	  v_acn_type := acn_rec.acn_type;
          RETURN(v_acn_type);
       END IF;
EXCEPTION
  WHEN others THEN
     RETURN('Not Available');
END get_acn_type;

begin
  if (FND_INSTALLATION.get_app_info ('OKC',
		     l_status,
		     l_industry,
		     l_schema)) then
    OKC_QUEUE_PVT.event_queue_name   := l_schema||'.'||'OKC_AQ_EV_QUEUE';
    OKC_QUEUE_PVT.outcome_queue_name := l_schema||'.'||'OKC_AQ_OC_QUEUE';
  else
    raise_application_error(-20000,
			    'Failed to get information for product '||
			    'OKC');
  end if;

end;

/

  GRANT EXECUTE ON "APPS"."OKC_QUEUE_PVT" TO "AQ_ADMINISTRATOR_ROLE";
  GRANT EXECUTE ON "APPS"."OKC_QUEUE_PVT" TO "OKC";
