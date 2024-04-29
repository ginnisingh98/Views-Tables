--------------------------------------------------------
--  DDL for Package Body EC_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EC_DRT_PKG" AS
/* $Header: ecedrtpkgb.plb 120.0.12010000.2 2018/05/10 10:04:47 saurabja noship $ */
  --
  -- Package Variables
  --
  L_PACKAGE VARCHAR2(33) DEFAULT 'EC_DRT_PKG.';

  PROCEDURE EC_TCA_DRC(PERSON_ID  IN NUMBER,
                       RESULT_TBL OUT NOCOPY PER_DRT_PKG.RESULT_TBL_TYPE) IS

    L_PROC         VARCHAR2(72);
    L_PERSON_ID    NUMBER := PERSON_ID;
    L_DEBUG        BOOLEAN := FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE;
    L_RESULT_TBL   PER_DRT_PKG.RESULT_TBL_TYPE;
    v_in_trans     NUMBER:=0;

  CURSOR get_pending_trans (v_person_id NUMBER)
      IS
        select count(*) from ece_tp_headers h , ece_stage s
         where h.tp_code=s.tp_code and
          (tp_header_id in ( select cas.tp_header_id from hz_cust_acct_sites_all cas, hz_cust_accounts ca,
           hz_parties par, hz_party_sites hps, hz_locations loc
           where cas.cust_account_id = ca.cust_account_id
           and cas.party_site_id = hps.party_site_id
           and hps.location_id = loc.location_id and hps.party_id = par.party_id
           and ca.party_id = par.party_id and cas.tp_header_id is not null
           and par.party_id =v_person_id ));

    BEGIN

    L_PROC := L_PACKAGE || 'EC_TCA_DRC';

    IF L_DEBUG THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_PROC, 'Entering: ' || L_PROC);
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_PROC, '  Checking constraints for PERSON_ID:' || L_PERSON_ID);
    END IF;

   OPEN get_pending_trans(L_PERSON_ID);
      FETCH get_pending_trans INTO v_in_trans;
   CLOSE get_pending_trans;


  if  v_in_trans > 0 then
      PER_DRT_PKG.add_to_results(person_id   => L_PERSON_ID,
                                 entity_type => 'TCA',
                                 status      => 'E',
                                 msgcode     => 'EC_IN_PENDING_TRANS',
                                 msgaplid    => 175, --BUG 27975546
                                 result_tbl  => L_RESULT_TBL);
  end if;


  RESULT_TBL := L_RESULT_TBL;

    IF L_DEBUG THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_PROC, 'Existing: ' || L_PROC);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
    if get_pending_trans%ISOPEN
      then
      close get_pending_trans;
    end if;

  END EC_TCA_DRC;

END EC_DRT_PKG;

/
