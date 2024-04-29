--------------------------------------------------------
--  DDL for Package Body OCM_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OCM_DRT_PKG" AS
/* $Header: OCMDRTPKB.pls 120.0.12010000.3 2018/03/30 06:04:42 bibeura noship $ */

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'Y');

  l_package varchar2(33) DEFAULT 'OCM_DRT_PKG. ';


/*=======================================================================+
 |  PROCEDURE write_log
 |  Implement log writer
 +=======================================================================*/

  PROCEDURE write_log
    (message       IN         varchar2
	,stage		 IN					varchar2) IS
  BEGIN

				if fnd_log.g_current_runtime_level<=fnd_log.level_procedure then
					fnd_log.string(fnd_log.level_procedure,message,stage);
				end if;
  END write_log;

/*=======================================================================+
 |  PROCEDURE add_to_results
 |  Implement helper procedure add record corresponding to an
 |  error/warning/error
 +=======================================================================*/
/*
  PROCEDURE add_to_results
    (  person_id     IN     number
	    ,entity_type	 IN			varchar2
	    ,status 		   IN			varchar2
     	,msgcode		   IN			varchar2
	    ,msgaplid		   IN			number
     ,result_tbl     IN OUT NOCOPY result_tbl_type) IS

	n number(15);

  BEGIN

	   n := result_tbl.count + 1;
    result_tbl(n).person_id := person_id;
    result_tbl(n).entity_type := entity_type;
    result_tbl(n).status := status;
    result_tbl(n).msgcode := msgcode;
    FND_MESSAGE.SET_NAME ('AR',msgcode);
    result_tbl(n).msgtext := FND_MESSAGE.GET;

  end add_to_results;

*/

/*=======================================================================+
 |  PROCEDURE ocm_tca_drc
 |  Implement Core HR specific DRC for TCA entity type
 +=======================================================================*/

  PROCEDURE ocm_tca_drc
		(person_id       IN         number
		,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type) IS

  l_proc varchar2(72);
  p_party_id varchar2(20);
  n number;
  l_temp varchar2(20);
  l_count number;

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug(  'ocm_tca_drc()+');
  END IF;

  p_party_id := person_id;


  l_count :=0;


  BEGIN

    SELECT  count(*) into l_count
    FROM    ar_cmgt_credit_requests cr
    WHERE   cr.party_id = p_party_id
    AND status in ('SAVE', 'SUBMIT', 'IN_PROCESS')
    AND ROWNUM = 1;

    IF (l_count <> 0) THEN

      IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug(  'ocm_fin_drc()-> Failure in credit requests');
      END IF;

  			per_drt_pkg.add_to_results
  			  (person_id => person_id
          ,entity_type => 'AR'
  			  ,status => 'E'
  			  ,msgcode => 'OCM_FIN_CREDIT_APP_EXISTS'
  			  ,msgaplid => 222
  			  ,result_tbl => result_tbl);


    END IF;

  END;

  l_count :=0;

  BEGIN
    SELECT  count(*)
    INTO    l_count
    FROM    ar_cmgt_case_folders cr
    WHERE   cr.party_id = p_party_id
    AND status in ('REFRESH', 'CREATED', 'SAVED')
    AND ROWNUM = 1;

    IF (l_count <> 0 ) THEN


      IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug(  'ocm_fin_drc()-> Failure in case folders');
      END IF;

  			per_drt_pkg.add_to_results
  			  (person_id => person_id
    			  ,entity_type => 'AR'
  			  ,status => 'E'
  			  ,msgcode => 'OCM_FIN_CASE_FOLDER_EXISTS'
  			  ,msgaplid => 222
  			  ,result_tbl => result_tbl);

    END IF;


  END;

END ocm_tca_drc;

/*=======================================================================+
 |  PROCEDURE ocm_hr_drc
 |  Implement Core HR specific DRC for HR entity type
 +=======================================================================*/

  PROCEDURE ocm_hr_drc
    (person_id       IN         number
    ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type) IS

  l_proc varchar2(72) := l_package|| 'ocm_hr_drc';
  BEGIN
    write_log ('Entering:'|| l_proc,'10');

    /* Skeleton Alone no action item as per Project */

    write_log ('Leaving:'|| l_proc,'10');
  END  ocm_hr_drc;



/*=======================================================================+
 |  PROCEDURE ocm_fnd_drc
 |  Implement Core HR specific DRC for FND entity type
 +=======================================================================*/

  PROCEDURE ocm_fnd_drc
    (person_id       IN         number
    ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type) IS

  l_proc varchar2(72) := l_package|| 'ocm_fnd_drc';
  BEGIN
    write_log ('Entering:'|| l_proc,'10');

    /* Skeleton Alone no action item as per Project */

    write_log ('Leaving:'|| l_proc,'10');
  END  ocm_fnd_drc;


END ocm_drt_pkg;

/
