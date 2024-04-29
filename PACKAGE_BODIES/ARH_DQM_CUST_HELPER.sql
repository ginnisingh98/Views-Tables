--------------------------------------------------------
--  DDL for Package Body ARH_DQM_CUST_HELPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARH_DQM_CUST_HELPER" AS
/*$Header: ARHDQMAB.pls 115.4 2002/05/31 18:34:16 pkm ship   $*/

FUNCTION Is_cust_role_rel_dqm_pty
( p_ctx_id               IN NUMBER,
  p_cust_account_role_id IN NUMBER,
  p_status               IN VARCHAR2)
RETURN VARCHAR2
IS
  ret   VARCHAR2(1);
  CURSOR c_exist IS
  SELECT 'Y'
    FROM hz_cust_account_roles  car,
         hz_cust_accounts       ca,
         hz_matched_parties_gt  mp
   WHERE car.cust_account_role_id = p_cust_account_role_id
     AND car.cust_account_id      = ca.cust_account_id
     AND DECODE(p_status,'ALL','ALL',NVL(car.status,'A'))= p_status
     AND ca.party_id              = mp.party_id
     AND mp.search_context_id     = p_ctx_id;
BEGIN
  OPEN c_exist;
  FETCH c_exist INTO ret;
  IF c_exist%NOTFOUND THEN
    ret := 'N';
  END IF;
  CLOSE c_exist;
  RETURN ret;
END;

FUNCTION is_cust_acct_in_pty_gt
------------------------------------------------------------------------
-- Return Y if the P_CUST_ACCOUNT_ID is already in HZ_MATCHED_PARTIES_GT
-- Otherwise N
------------------------------------------------------------------------
( p_ctx_id               IN NUMBER,
  p_cust_account_id      IN NUMBER,
  p_status               IN VARCHAR2)
RETURN VARCHAR2
IS
  CURSOR c1 IS
  SELECT 'Y'
    FROM hz_matched_parties_gt  a,
         hz_cust_accounts       b
   WHERE a.search_context_id = p_ctx_id
     AND -a.party_id         = p_cust_account_id
     AND b.cust_account_id   = p_cust_account_id
     AND DECODE(p_status, 'ALL', 'ALL', NVL(b.status,'A')) = p_status
     AND a.score             < 0;
  ret  VARCHAR2(1);
BEGIN
  OPEN c1;
  FETCH c1 INTO ret;
  IF c1%NOTFOUND THEN
    ret := 'N';
  END IF;
  CLOSE c1;
  RETURN ret;
END;

FUNCTION is_cust_role_in_ct_gt
---------------------------------------------------------------------------------------
-- Return Y if the P_CUST_ACCOUNR_ROLE_ID is already inserted in HZ_MATCHED_CONTACTS_GT
-- Otherwise N
---------------------------------------------------------------------------------------
( p_ctx_id               IN NUMBER,
  p_cust_account_role_id IN NUMBER,
  p_cust_account_id      IN NUMBER,
  p_status               IN VARCHAR2)
RETURN VARCHAR2
IS
  CURSOR c1 IS
  SELECT 'Y'
    FROM hz_matched_contacts_gt a,
         hz_cust_account_roles  b
   WHERE a.search_context_id    =  p_ctx_id
     AND -a.party_id            =  p_cust_account_id
     AND -a.org_contact_id      =  p_cust_account_role_id
     AND b.cust_account_role_id =  p_cust_account_role_id
     AND DECODE(p_status,'ALL','ALL',NVL(b.status,'A')) = p_status
     AND a.score               < 0;
  ret    VARCHAR2(1);
BEGIN
  OPEN c1;
  FETCH c1 INTO ret;
  IF c1%NOTFOUND THEN
     ret := 'N';
  END IF;
  CLOSE c1;
  RETURN ret;
END;

FUNCTION Is_acct_site_in_ps_gt
---------------------------------------------------------------------------------------
-- Return Y if the P_CUST_ACCT_SITE_ID is already inserted in HZ_MATCHED_PARTY_SITES_GT
-- Otherwise N
---------------------------------------------------------------------------------------
( p_ctx_id            IN NUMBER,
  p_cust_acct_site_id IN NUMBER,
  p_cust_account_id   IN NUMBER,
  p_cur_all           IN VARCHAR2,
  p_status            IN VARCHAR2)
RETURN VARCHAR2
IS
  CURSOR c1 IS
  SELECT 'Y'
    FROM hz_matched_party_sites_gt a,
         hz_cust_acct_sites        b
   WHERE a.search_context_id     = p_ctx_id
     AND -a.party_id          = p_cust_account_id
     AND -a.party_site_id     = p_cust_acct_site_id
     AND b.cust_account_id   = p_cust_account_id
     AND b.cust_acct_site_id = p_cust_acct_site_id
     AND DECODE(p_status,'ALL','ALL',NVL(b.status,'A')) = p_status
     AND a.score < 0;

  CURSOR c2 IS
  SELECT 'Y'
    FROM hz_matched_party_sites_gt a,
         hz_cust_acct_sites_all    b
   WHERE a.search_context_id     = p_ctx_id
     AND -a.party_id          = p_cust_account_id
     AND -a.party_site_id     = p_cust_acct_site_id
     AND b.cust_account_id   = p_cust_account_id
     AND b.cust_acct_site_id = p_cust_acct_site_id
     AND DECODE(p_status,'ALL','ALL',NVL(b.status,'A')) = p_status
     AND a.score < 0;
   ret  VARCHAR2(1);
BEGIN
  IF p_cur_all     = 'CUR' THEN
    OPEN c1;
    FETCH c1 INTO ret;
    IF c1%NOTFOUND THEN
      ret := 'N';
    END IF;
    CLOSE c1;
  ELSIF  p_cur_all = 'ALL' THEN
    OPEN c2;
    FETCH c2 INTO ret;
    IF c2%NOTFOUND THEN
      ret := 'N';
    END IF;
    CLOSE c2;
  END IF;
  RETURN ret;
END;

FUNCTION is_as_rel_dqm_pty
--------------------------------------------------------------------------------------------
-- Return Y if the P_CUST_ACCT_SITE_D is associated with a party_id in HZ_MATCHED_PARTIES_GT
-- Otherwise N
--------------------------------------------------------------------------------------------
( p_ctx_id             IN NUMBER,
  p_cust_account_id    IN NUMBER,
  p_cust_acct_site_id  IN NUMBER,
  p_cur_all            IN VARCHAR2,
  p_status             IN VARCHAR2)
RETURN VARCHAR2
IS
  CURSOR c1 IS
  SELECT 'Y'
    FROM hz_cust_acct_sites         a,
         hz_party_sites             c,
         hz_matched_parties_gt      d,
         hz_parties                 e
   WHERE a.cust_account_id                     = p_cust_account_id
     AND a.cust_acct_site_id                   = p_cust_acct_site_id
     AND DECODE(p_status,'ALL','ALL',NVL(a.status,'A')) = p_status
     AND a.party_site_id                       = c.party_site_id
     AND DECODE(p_status,'ALL','ALL',NVL(c.status,'A')) = p_status
     AND c.party_id                            = d.party_id
     AND NVL(d.score,0)                        >= 0
     AND d.search_context_id                   = p_ctx_id
     AND d.party_id                            = e.party_id
     AND DECODE(p_status,'ALL','ALL',NVL(e.status,'A')) = p_status;

  CURSOR c2 IS
  SELECT 'Y'
    FROM hz_cust_acct_sites_all     a,
         hz_party_sites             c,
         hz_matched_parties_gt      d,
         hz_parties                 e
   WHERE a.cust_account_id                     = p_cust_account_id
     AND a.cust_acct_site_id                   = p_cust_acct_site_id
     AND DECODE(p_status,'ALL','ALL',NVL(a.status,'A')) = p_status
     AND a.party_site_id                       = c.party_site_id
     AND DECODE(p_status,'ALL','ALL',NVL(c.status,'A')) = p_status
     AND c.party_id                            = d.party_id
     AND NVL(d.score,0)                        >= 0
     AND d.search_context_id                   = p_ctx_id
     AND d.party_id                            = e.party_id
     AND DECODE(p_status,'ALL','ALL',NVL(e.status,'A')) = p_status;

  ret  VARCHAR2(1);
BEGIN
  IF p_cur_all = 'CUR' THEN
    OPEN c1;
    FETCH c1 INTO ret;
    IF c1%NOTFOUND THEN
       ret := 'N';
    END IF;
    CLOSE c1;
  ELSIF p_cur_all = 'ALL' THEN
    OPEN c2;
    FETCH c2 INTO ret;
    IF c2%NOTFOUND THEN
       ret := 'N';
    END IF;
    CLOSE c2;
  END IF;
  RETURN ret;
END;

FUNCTION score_of_rel_ps
-------------------------------------------------------------------------------------------------------
-- Return the score of the party_site related to a cust_acct_site in HZ_MATCHED_PARTY_SITES_GT if found
-- Otherwise -99999
-------------------------------------------------------------------------------------------------------
( p_ctx_id             IN NUMBER,
  p_cust_acct_site_id  IN NUMBER,
  p_cur_all            IN VARCHAR2,
  p_status             IN VARCHAR2)
RETURN NUMBER
IS
  CURSOR c1 IS
  SELECT NVL(b.score,0)
    FROM hz_cust_acct_sites        a,
         hz_matched_party_sites_gt b,
         hz_party_sites            c
   WHERE a.cust_acct_site_id                   = p_cust_acct_site_id
     AND DECODE(p_status,'ALL','ALL',NVL(a.status,'A')) = p_status
     AND a.party_site_id                       = b.party_site_id
     AND b.search_context_id                   = p_ctx_id
     AND NVL(b.score,0)                        >= 0
     AND b.party_site_id                       = c.party_site_id
     AND DECODE(p_status,'ALL','ALL',NVL(c.status,'A')) = p_status;

  CURSOR c2 IS
  SELECT NVL(b.score,0)
    FROM hz_cust_acct_sites_all    a,
         hz_matched_party_sites_gt b,
         hz_party_sites            c
   WHERE a.cust_acct_site_id                   = p_cust_acct_site_id
     AND DECODE(p_status,'ALL','ALL',NVL(a.status,'A')) = p_status
     AND a.party_site_id                       = b.party_site_id
     AND b.search_context_id                   = p_ctx_id
     AND NVL(b.score,0)                        >= 0
     AND b.party_site_id                       = c.party_site_id
     AND DECODE(p_status,'ALL','ALL',NVL(c.status,'A')) = p_status;

  ret  NUMBER;
BEGIN
  IF    p_cur_all = 'CUR' THEN
    OPEN c1;
    FETCH c1 INTO ret;
    IF c1%NOTFOUND THEN
      ret := -99999;
    END IF;
    CLOSE c1;
  ELSIF p_cur_all = 'ALL' THEN
    OPEN c2;
    FETCH c2 INTO ret;
    IF c2%NOTFOUND THEN
      ret := -99999;
    END IF;
    CLOSE c2;
  END IF;
  RETURN ret;
END;

PROCEDURE ins_as_in_ps_gt
-------------------------------------------------------------------------
-- Insert in CUST_ACCT_SITE_ID in HZ_MATCHED_PARTY_SITES_GT
-- If 1) the cust_acct_site_id is related to a matched party
--    2) the cust_acct_site_id is not yet in HZ_MATCHED_PARTY_SITES_GT
-------------------------------------------------------------------------
--  CUST_ACCOUNT_ID  CUST_ACCT_SITE_ID   -PSscore(-1)   SEARCH_CONTEXT_ID
-------------------------------------------------------------------------
( p_ctx_id             IN NUMBER,
  p_cust_account_id    IN NUMBER,
  p_cust_acct_site_id  IN NUMBER,
  p_cur_all            IN VARCHAR2,
  p_status             IN VARCHAR2)
IS
  lyn         VARCHAR2(1);
  l_ps_score  NUMBER;
BEGIN
  lyn := is_as_rel_dqm_pty(p_ctx_id             => p_ctx_id,
                           p_cust_account_id    => p_cust_account_id,
                           p_cust_acct_site_id  => p_cust_acct_site_id,
                           p_cur_all            => p_cur_all,
                           p_status             => p_status);

  IF lyn = 'Y' THEN
    lyn := Is_acct_site_in_ps_gt(p_ctx_id            => p_ctx_id,
                                 p_cust_acct_site_id => p_cust_acct_site_id,
                                 p_cust_account_id   => p_cust_account_id,
                                 p_cur_all           => p_cur_all,
                                 p_status            => p_status);
    IF lyn = 'N' THEN

      l_ps_score := score_of_rel_ps( p_ctx_id             => p_ctx_id,
                                     p_cust_acct_site_id  => p_cust_acct_site_id,
                                     p_cur_all            => p_cur_all,
                                     p_status             => p_status);
       IF l_ps_score > 0 THEN
         l_ps_score  := -l_ps_score;
       ELSE
         l_ps_score  := -1;
       END IF;

       INSERT INTO hz_matched_party_sites_gt
       ( PARTY_ID         , PARTY_SITE_ID          ,SCORE        , SEARCH_CONTEXT_ID ) VALUES
       ( -p_cust_account_id, -p_cust_acct_site_id    ,l_ps_score   , p_ctx_id          );

    END IF;

  END IF;

END;

--HYU
PROCEDURE car_oc_treatment
( p_ctx_id       IN   NUMBER,
  p_cur_all      IN   VARCHAR2,
  p_status       IN   VARCHAR2)
IS
  CURSOR c1 IS
  SELECT party_id,
         org_contact_id,
         score
    FROM hz_matched_contacts_gt
   WHERE search_context_id =  p_ctx_id
     AND score             >= 0;
  lrec  c1%ROWTYPE;
BEGIN
  OPEN c1;
  LOOP
    FETCH c1 INTO lrec;
    EXIT WHEN c1%NOTFOUND;
    ins_ca_car_in_gt( p_ctx_id         => p_ctx_id,
                      p_org_contact_id => lrec.org_contact_id,
                      p_cur_all        => p_cur_all,
                      p_status         => p_status);
  END LOOP;
  CLOSE c1;
END;

FUNCTION is_as_rel_ps_gt
( p_ctx_id       IN NUMBER,
  p_acct_site_id IN NUMBER,
  p_cur_all      IN VARCHAR2,
  p_status       IN VARCHAR2)
RETURN VARCHAR2
IS
  CURSOR c1 IS
  SELECT 'Y'
    FROM hz_matched_party_sites_gt a,
         hz_cust_acct_sites        b
   WHERE a.search_context_id = p_ctx_id
     AND NVL(a.score,0)      >= 0
     AND a.party_site_id     = b.party_site_id
     AND b.cust_acct_site_id = p_acct_site_id
     AND DECODE(p_status, 'ALL','ALL', NVL(b.status,'A')) = p_status;

  CURSOR c2 IS
  SELECT 'Y'
    FROM hz_matched_party_sites_gt a,
         hz_cust_acct_sites_all    b
   WHERE a.search_context_id = p_ctx_id
     AND NVL(a.score,0)      >= 0
     AND a.party_site_id     = b.party_site_id
     AND b.cust_acct_site_id = p_acct_site_id
     AND DECODE(p_status, 'ALL','ALL', NVL(b.status,'A')) = p_status;

  ret VARCHAR2(1);
BEGIN
  IF p_cur_all = 'CUR' THEN
    OPEN c1;
    FETCH c1 INTO ret;
    IF c1%NOTFOUND THEN
      ret := 'N';
    END IF;
    CLOSE c1;
  ELSIF p_cur_all = 'ALL' THEN
    OPEN c2;
    FETCH c2 INTO ret;
    IF c2%NOTFOUND THEN
      ret := 'N';
    END IF;
    CLOSE c2;
  END IF;
  RETURN ret;
END;

PROCEDURE ins_ca_car_in_gt
-------------------------------------------------------------------
-- Treatement for HZ_CUST_ACCOUNT_ROLES
-------------------------------------------------------------------
( p_ctx_id          IN NUMBER,
  p_org_contact_id  IN NUMBER,
  p_cur_all         IN VARCHAR2,
  p_status          IN VARCHAR2)
IS
  CURSOR c1 IS
  SELECT a.score                ct_score,
         f.score                pty_score,
         d.cust_account_role_id,
         d.cust_account_id,
         d.cust_acct_site_id
    FROM hz_matched_contacts_gt a,
         hz_org_contacts        b,
         hz_relationships       c,
         hz_cust_account_roles  d,
         hz_cust_accounts       e,
         hz_matched_parties_gt  f,
         hz_parties             g
   WHERE a.search_context_id                   = p_ctx_id
     AND a.org_contact_id                      = p_org_contact_id
     AND NVL(a.score,0)                        >= 0
     AND a.org_contact_id                      = b.org_contact_id
     AND DECODE(p_status,'ALL','ALL',NVL(b.status,'A')) = p_status
     AND b.party_relationship_id               = c.relationship_id
     AND c.directional_flag                    = 'F'
     AND c.party_id                            = d.party_id
     AND DECODE(p_status,'ALL','ALL',NVL(d.status,'A')) = p_status
     AND d.cust_account_id                     = e.cust_account_id
     AND DECODE(p_status,'ALL','ALL',NVL(e.status,'A')) = p_status
     AND e.party_id                            = f.party_id
     AND f.search_context_id                   = p_ctx_id
     AND NVL(f.score,0)                        >= 0
     AND f.party_id                            = a.party_id
     AND f.party_id                            = g.party_id
     AND DECODE(p_status,'ALL','ALL', NVL(g.status,'A'))= p_status;
  lrec   c1%ROWTYPE;
  lyn    VARCHAR2(1);
  l_score  VARCHAR2(30);
BEGIN
  OPEN c1;
  FETCH c1 INTO lrec;
  IF c1%NOTFOUND THEN
    NULL;
  ELSE
    ------------------------------------------------------
    --{ Insert Cust Account Role in HZ_MATCHED_CONTACTS_GT
    ------------------------------------------------------
    lyn := is_cust_role_in_ct_gt( p_ctx_id               => p_ctx_id,
                                    p_cust_account_role_id => lrec.cust_account_role_id,
                                    p_cust_account_id      => lrec.cust_account_id,
                                    p_status               => p_status);
    IF lyn = 'N' THEN

      IF lrec.cust_acct_site_id IS NULL THEN

        IF lrec.ct_score IS NULL THEN
          l_score  :=  -1;
        ELSE
          l_score  :=  -lrec.ct_score;
        END IF;
        INSERT INTO hz_matched_contacts_gt
        ( PARTY_ID            , ORG_CONTACT_ID           ,  SCORE    , SEARCH_CONTEXT_ID) VALUES
        ( -lrec.cust_account_id, -lrec.cust_account_role_id,  l_score  , p_ctx_id         );

        ------------------------------------------------
        --{ C Insert Cust Account in HZ_MATCHED_PARTIES_GT
        ------------------------------------------------
        lyn  := is_cust_acct_in_pty_gt( p_ctx_id          => p_ctx_id,
                                      p_cust_account_id => lrec.cust_account_id,
                                      p_status          => p_status);
        IF lyn = 'N' THEN
          IF lrec.pty_score IS NULL THEN
            l_score  :=  -1;
          ELSE
            l_score  :=  -lrec.pty_score;
          END IF;
          INSERT INTO hz_matched_parties_gt
          ( PARTY_ID            , SCORE       , SEARCH_CONTEXT_ID  ) VALUES
          ( -lrec.cust_account_id, l_score     , p_ctx_id           );
        END IF;
        --}

      ELSIF lrec.cust_acct_site_id IS NOT NULL THEN
      --       otherwise check if the cust_acct_site_id belongs is related to one of the party_site in gt
      --                        if y then INSERT cust_account_role + B + C
--HYU
        lyn := is_as_rel_ps_gt(p_ctx_id       => p_ctx_id,
                           p_acct_site_id => lrec.cust_acct_site_id,
                           p_cur_all      => p_cur_all,
                           p_status       => p_status);
        IF lyn = 'Y' THEN
          IF lrec.ct_score IS NULL THEN
            l_score  :=  -1;
          ELSE
            l_score  :=  -lrec.ct_score;
          END IF;
          INSERT INTO hz_matched_contacts_gt
          ( PARTY_ID            , ORG_CONTACT_ID           ,  SCORE    , SEARCH_CONTEXT_ID) VALUES
          ( -lrec.cust_account_id, -lrec.cust_account_role_id,  l_score  , p_ctx_id         );

          ---------------------------------------------------------
          --{ B Insert Cust_Acct_site_id in HZ_MATCHED_PARTY_SITES_GT
          ---------------------------------------------------------
          ins_as_in_ps_gt( p_ctx_id             => p_ctx_id,
                       p_cust_account_id    => lrec.cust_account_id,
                       p_cust_acct_site_id  => lrec.cust_acct_site_id,
                       p_cur_all            => p_cur_all,
                       p_status             => p_status);
          --}

          ------------------------------------------------
          --{ C Insert Cust Account in HZ_MATCHED_PARTIES_GT
          ------------------------------------------------
          lyn  := is_cust_acct_in_pty_gt( p_ctx_id          => p_ctx_id,
                                      p_cust_account_id => lrec.cust_account_id,
                                      p_status          => p_status);
          IF lyn = 'N' THEN
            IF lrec.pty_score IS NULL THEN
               l_score  :=  -1;
            ELSE
               l_score  :=  -lrec.pty_score;
            END IF;
            INSERT INTO hz_matched_parties_gt
            ( PARTY_ID            , SCORE       , SEARCH_CONTEXT_ID  ) VALUES
            ( -lrec.cust_account_id, l_score     , p_ctx_id           );

          END IF;
          --}
        END IF;
     -- HYU Replacement }
      END IF;
    END IF;
  END IF;
END;

--HYU

FUNCTION score_rel_party
( p_ctx_id           IN NUMBER,
  p_cust_account_id  IN NUMBER,
  p_status           IN VARCHAR2)
RETURN NUMBER
IS
  CURSOR c1 IS
  SELECT NVL(score,0)
    FROM hz_cust_accounts      a,
         hz_matched_parties_gt b
   WHERE a.cust_account_id   = p_cust_account_id
     AND b.search_context_id = p_ctx_id
     AND a.party_id          = b.party_id
     AND NVL(b.score,0)      >= 0
     AND DECODE(p_status,'ALL','ALL',NVL(a.status,'A')) = p_status;
  ret NUMBER;
BEGIN
  OPEN c1;
  FETCH c1 INTO ret;
  IF c1%NOTFOUND THEN
    ret := -99999;
  END IF;
  CLOSE c1;
  RETURN ret;
END;


PROCEDURE find_as_rel_ps
-----------------------------------------------------------------------------------------------
-- INSERT all the CUST_ACCT_SITE_ID related to the P_PARTY_SITE_ID in HZ_MATCHED_PARTY_SITES_GT
--        If necesary insert also the CUST_ACCOUNT_ID related in  HZ_MATCHED_PARTIES_GT
-----------------------------------------------------------------------------------------------
( p_ctx_id          IN NUMBER,
  p_party_site_id   IN NUMBER,
  p_score           IN NUMBER,
  p_cur_all         IN VARCHAR2,
  p_status          IN VARCHAR2)
IS
  TYPE nrc  IS REF CURSOR;
  cv   nrc;
  l_cust_acct_site_id  NUMBER;
  l_cust_account_id    NUMBER;
  lyn     VARCHAR2(1);
  l_score NUMBER;
BEGIN
  IF p_cur_all = 'CUR' THEN
    OPEN cv FOR
     SELECT cust_acct_site_id,
            cust_account_id
       FROM hz_cust_acct_sites
      WHERE party_site_id = p_party_site_id
        AND DECODE(p_status,'ALL','ALL',NVL(status,'A')) = p_status;
  ELSIF p_cur_all = 'ALL' THEN
    OPEN cv FOR
     SELECT cust_acct_site_id,
            cust_account_id
       FROM hz_cust_acct_sites_all
      WHERE party_site_id = p_party_site_id
        AND DECODE(p_status,'ALL','ALL',NVL(status,'A')) = p_status;
  END IF;

  IF cv%ISOPEN THEN
  LOOP
    FETCH cv INTO l_cust_acct_site_id, l_cust_account_id;
    EXIT WHEN cv%NOTFOUND;

    --{ Treatment of acct_site
    lyn := is_as_rel_dqm_pty( p_ctx_id            => p_ctx_id,
                              p_cust_account_id   => l_cust_account_id,
                              p_cust_acct_site_id => l_cust_acct_site_id,
                              p_cur_all           => p_cur_all,
                              p_status            => p_status);
    IF lyn = 'Y' THEN
      IF p_score = 0 THEN
        l_score := -1;
      ELSE
        l_score := -p_score;
      END IF;
      INSERT INTO hz_matched_party_sites_gt
      ( PARTY_ID            , PARTY_SITE_ID          ,SCORE        , SEARCH_CONTEXT_ID ) VALUES
      ( -l_cust_account_id   , -l_cust_acct_site_id    ,l_score      , p_ctx_id          );
    END IF;
    --}

    --{ Treatment of cust_account
    lyn := is_cust_acct_in_pty_gt( p_ctx_id            => p_ctx_id,
                                   p_cust_account_id   => l_cust_account_id,
                                   p_status            => p_status);
    IF lyn = 'N' THEN
      l_score := score_rel_party( p_ctx_id          => p_ctx_id,
                                  p_cust_account_id => l_cust_account_id,
                                  p_status          => p_status);
      IF l_score <> -99999 THEN
        IF   l_score > 0 THEN
          l_score := -l_score;
        ELSE
          l_score := -1;
        END IF;
        INSERT INTO hz_matched_parties_gt
        ( PARTY_ID            , SCORE       , SEARCH_CONTEXT_ID  ) VALUES
        ( -l_cust_account_id   , l_score     , p_ctx_id           );
      END IF;
    END IF;
    --}
  END LOOP;
  CLOSE cv;
  END IF;
END;


FUNCTION is_as_rel_ps_in_ps_gt
------------------------------------------------------------------------------------------------------
-- Return Y if the CUST_ACCT_SITE_ID related to the P_PARTY_SITE_ID exist in HZ_MATCHED_PARTY_SITES_GT
------------------------------------------------------------------------------------------------------
( p_ctx_id          IN NUMBER,
  p_party_site_id   IN NUMBER,
  p_cur_all         IN VARCHAR2,
  p_status          IN VARCHAR2)
RETURN VARCHAR2
IS
  CURSOR c1 IS
  SELECT 'Y'
    FROM hz_cust_acct_sites        b,
         hz_matched_party_sites_gt c
   WHERE b.party_site_id     = p_party_site_id
     AND b.cust_acct_site_id = -c.party_site_id
     AND c.search_context_id = p_ctx_id
     AND c.score              <  0
     AND DECODE(p_status,'ALL','ALL',NVL(b.status,'A')) = p_status;

  CURSOR c2 IS
  SELECT 'Y'
    FROM hz_cust_acct_sites_all    b,
         hz_matched_party_sites_gt c
   WHERE b.party_site_id     = p_party_site_id
     AND b.cust_acct_site_id = -c.party_site_id
     AND c.search_context_id = p_ctx_id
     AND c.score              <  0
     AND DECODE(p_status,'ALL','ALL',NVL(b.status,'A')) = p_status;

  ret VARCHAR2(1);
BEGIN
  IF p_cur_all = 'CUR' THEN
    OPEN c1;
    FETCH c1 INTO ret;
    IF c1%NOTFOUND THEN
      ret := 'N';
    END IF;
    CLOSE c1;
  ELSIF p_cur_all = 'ALL' THEN
    OPEN c2;
    FETCH c2 INTO ret;
    IF c2%NOTFOUND THEN
      ret := 'N';
    END IF;
    CLOSE c2;
  END IF;
  RETURN ret;
END;

FUNCTION is_any_oc_rel_ps
( p_ctx_id   IN NUMBER,
  p_ps_id    IN NUMBER,
  p_status   IN VARCHAR2)
RETURN VARCHAR2
IS
  CURSOR c1 IS
  SELECT 'Y'
    FROM hz_matched_contacts_gt a,
         hz_org_contacts        b
   WHERE a.search_context_id                           = p_ctx_id
     AND NVL(a.score,0)                                >= 0
     AND a.org_contact_id                              = b.org_contact_id
     AND b.party_site_id                               = p_ps_id
     AND DECODE(p_status,'ALL','ALL',NVL(p_status,'A'))= p_status;
  ret  VARCHAR2(1);
BEGIN
  OPEN c1;
  FETCH c1 INTO ret;
  IF c1%NOTFOUND THEN
    ret := 'N';
  END IF;
  CLOSE c1;
  RETURN ret;
END;

FUNCTION is_ps_rel_cpt_gt
( p_ctx_id    IN  NUMBER,
  p_ps_id     IN  NUMBER,
  p_status    IN VARCHAR2)
RETURN VARCHAR2
IS
  CURSOR c1 IS
  SELECT 'Y'
    FROM hz_matched_cpts_gt a,
         hz_contact_points b
   WHERE a.search_context_id =  p_ctx_id
     AND a.contact_point_id  =  b.contact_point_id
     AND b.owner_table_name  =  'HZ_PARTY_SITES'
     AND b.owner_table_id    =  p_ps_id
     AND DECODE(p_status,'ALL','ALL',NVL(b.status,'A')) = p_status;
  ret VARCHAR2(1);
BEGIN
  OPEN c1;
  FETCH c1 INTO ret;
  IF c1%NOTFOUND THEN
    ret := 'N';
  END IF;
  CLOSE c1;
  RETURN ret;
END;

PROCEDURE as_ps_treatment
------------------------------------------------------------------------
-- Cust Account Site / Party Site treatment in HZ_MATCHED_PARTY_SITES_GT
------------------------------------------------------------------------
( p_ctx_id      IN NUMBER  ,
  p_cur_all     IN VARCHAR2,
  p_status      IN VARCHAR2 )
IS
  CURSOR c1 IS
  SELECT a.party_site_id,
         NVL(a.score,0) score
    FROM hz_matched_party_sites_gt a
   WHERE a.search_context_id  = p_ctx_id
     AND NVL(a.score,0)       >= 0;

  lrec  c1%ROWTYPE;
  lyn   VARCHAR2(1);

BEGIN
  OPEN c1;
  LOOP
    FETCH c1 INTO lrec;
    EXIT WHEN c1%NOTFOUND;
/*
insert into hyu_matched_party_sites_gt
(PARTY_ID                       ,
 PARTY_SITE_ID                  ,
 SCORE                          ,
 SEARCH_CONTEXT_ID              ) values
('9999',
 lrec.party_site_id,
 lrec.score,
 p_ctx_id);
*/
    lyn := is_as_rel_ps_in_ps_gt( p_ctx_id        => p_ctx_id,
                                  p_party_site_id => lrec.party_site_id,
                                  p_cur_all       => p_cur_all,
                                  p_status        => p_status);
/*
insert into hyu_err
(COL1,
 COL2,
 COLN) values
(lrec.party_site_id,
 lyn||' - '||p_cur_all||' - '||p_status,
 p_ctx_id);
 */


    IF lyn = 'Y' THEN
       NULL;
    ELSE
      IF lrec.score >= 0 THEN

--HYU 130202
        lyn := is_ps_rel_cpt_gt( p_ctx_id    => p_ctx_id,
                                 p_ps_id     => lrec.party_site_id,
                                 p_status    => p_status);
        IF lyn = 'Y' THEN
           find_as_rel_ps( p_ctx_id        => p_ctx_id,
                           p_party_site_id => lrec.party_site_id,
                           p_score         => lrec.score,
                           p_cur_all       => p_cur_all,
                           p_status        => p_status);
        ELSE
          lyn := is_any_oc_rel_ps( p_ctx_id   => p_ctx_id,
                                  p_ps_id    => lrec.party_site_id,
                                  p_status   => p_status);
          IF lyn = 'N' THEN
            find_as_rel_ps( p_ctx_id        => p_ctx_id,
                           p_party_site_id => lrec.party_site_id,
                           p_score         => lrec.score,
                           p_cur_all       => p_cur_all,
                           p_status        => p_status);
          END IF;
        END IF;
      END IF;
    END IF;
  END LOOP;
  CLOSE c1;
END;


FUNCTION is_any_data_rel_pty
( p_ctx_id   IN NUMBER,
  p_party_id IN NUMBER,
  p_status   IN VARCHAR2)
RETURN VARCHAR2
IS
  CURSOR c1 IS
  SELECT 'Y'
    FROM hz_matched_party_sites_gt
   WHERE search_context_id = p_ctx_id
     AND NVL(score,0)      >= 0
     AND party_id          = p_party_id;

  CURSOR c2 IS
  SELECT 'Y'
    FROM hz_matched_contacts_gt
   WHERE search_context_id = p_ctx_id
     AND NVL(score,0) >= 0
     AND party_id      = p_party_id;
/*
  CURSOR c3 IS
  SELECT 'Y'
    FROM hz_matched_cpts_gt
   WHERE search_context_id = p_ctx_id
     AND NVL(score,0)  >= 0
     AND party_id       = p_party_id;
*/
  ret VARCHAR2(1);
BEGIN
  OPEN c1;
  FETCH c1 INTO ret;
  IF c1%NOTFOUND THEN
      OPEN c2;
      FETCH c2 INTO ret;
      IF c2%NOTFOUND THEN
         ret := 'N';
/*
         OPEN c3;
         FETCH c3 INTO ret;
         IF c3%NOTFOUND THEN
           ret := 'N';
         END IF;
         CLOSE c3;
*/
      END IF;
      CLOSE c2;
  END IF;
  CLOSE c1;
  RETURN ret;
END;

FUNCTION is_pty_rel_cpt_gt
( p_ctx_id   IN NUMBER,
  p_pty_id   IN NUMBER,
  p_status   IN VARCHAR2)
RETURN VARCHAR2
IS
  CURSOR c1 IS
  SELECT 'Y'
    FROM hz_matched_cpts_gt a,
         hz_contact_points  b
   WHERE a.search_context_id =  p_ctx_id
     AND a.contact_point_id  =  b.contact_point_id
     AND b.owner_table_name  =  'HZ_PARTIES'
     AND b.owner_table_id    =  p_pty_id
     AND DECODE(p_status,'ALL','ALL',NVL(b.status,'A')) = p_status;
  ret  VARCHAR2(1);
BEGIN
  OPEN c1;
  FETCH c1 INTO ret;
  IF c1%NOTFOUND THEN
    ret := 'N';
  END IF;
  CLOSE c1;
  RETURN ret;
END;

PROCEDURE ac_pty_treatment
-------------------------------------------------------
-- Account / Party Treatement in HZ_MATCHED_PARTIES_GT
-------------------------------------------------------
( p_ctx_id     IN NUMBER,
  p_cur_all    IN VARCHAR2,
  p_status     IN VARCHAR2)
IS
  CURSOR c1 IS
  SELECT party_id,
         NVL(score,0) score
    FROM hz_matched_parties_gt
   WHERE NVL(score,0) >= 0
     AND search_context_id = p_ctx_id;
  lrec c1%ROWTYPE;
  lyn  VARCHAR2(1);
BEGIN
  OPEN c1;
  LOOP
    FETCH c1 INTO lrec;
    EXIT WHEN c1%NOTFOUND;
    lyn :=  is_ac_rel_pty_in_p_gt( p_ctx_id   => p_ctx_id,
                                   p_party_id => lrec.party_id,
                                   p_status   => p_status);

    IF lyn = 'Y' THEN
      NULL;
    ELSE
      IF lrec.score >= 0 THEN

        lyn := is_pty_rel_cpt_gt( p_ctx_id  => p_ctx_id,
                                  p_pty_id  => lrec.party_id,
                                  p_status  => p_status);
        IF lyn = 'Y' THEN
           find_all_account_for_party( p_ctx_id    => p_ctx_id,
                                       p_party_id  => lrec.party_id,
                                       p_score     => lrec.score,
                                       p_cur_all   => p_cur_all,
                                       p_status    => p_status);
        ELSE
          lyn := is_any_data_rel_pty( p_ctx_id   => p_ctx_id,
                                    p_party_id => lrec.party_id,
                                    p_status   => p_status);
          IF lyn = 'N' THEN
            find_all_account_for_party( p_ctx_id    => p_ctx_id,
                                       p_party_id  => lrec.party_id,
                                       p_score     => lrec.score,
                                       p_cur_all   => p_cur_all,
                                       p_status    => p_status);
          END IF;
        END IF;
      END IF;
    END IF;
  END LOOP;
  CLOSE c1;
END;


FUNCTION is_any_cs_in_cur_org
(p_cust_account_id IN NUMBER,
 p_status          IN VARCHAR2)
RETURN VARCHAR2
IS
 CURSOR c1 IS
 SELECT 'Y'
   FROM hz_cust_acct_sites
  WHERE cust_account_id = p_cust_account_id
    AND DECODE(p_status, 'ALL','ALL',NVL(status,'A')) = p_status;
 lyn  VARCHAR2(1);
BEGIN
  OPEN c1;
  FETCH c1 INTO lyn;
  IF c1%NOTFOUND THEN
    lyn := 'N';
  END IF;
  CLOSE c1;
  RETURN lyn;
END;

PROCEDURE find_all_account_for_party
-------------------------------------------------------------------------
-- INSERT all_cust_account related to P_PARTY_ID in HZ_MATCHED_PARTIES_GT
-------------------------------------------------------------------------
( p_ctx_id    IN NUMBER,
  p_party_id  IN NUMBER,
  p_score     IN NUMBER,
  p_cur_all   IN VARCHAR2,
  p_status    IN VARCHAR2)
IS
  CURSOR c1 IS
  SELECT cust_account_id
    FROM hz_cust_accounts
   WHERE party_id  = p_party_id
     AND DECODE(p_status, 'ALL','ALL',NVL(status,'A')) = p_status;
  lrec     c1%ROWTYPE;
  l_score  NUMBER;
BEGIN
  OPEN c1;
  LOOP
    FETCH c1 INTO lrec;
    EXIT WHEN c1%NOTFOUND;
    IF p_score > 0 THEN
       l_score := -p_score;
    ELSE
       l_score := -1;
    END IF;
    IF    p_cur_all = 'ALL' THEN
      INSERT INTO hz_matched_parties_gt
      ( PARTY_ID            , SCORE       , SEARCH_CONTEXT_ID  ) VALUES
      ( -lrec.cust_account_id, l_score     , p_ctx_id           );
    ELSIF p_cur_all = 'CUR' THEN
      IF  is_any_cs_in_cur_org(lrec.cust_account_id,p_status) = 'Y' THEN
        INSERT INTO hz_matched_parties_gt
        ( PARTY_ID            , SCORE       , SEARCH_CONTEXT_ID  ) VALUES
        ( -lrec.cust_account_id, l_score     , p_ctx_id           );
      END IF;
    END IF;
  END LOOP;
  CLOSE c1;
END;


FUNCTION is_ac_rel_pty_in_p_gt
------------------------------------------------------------------------------------------------
-- RETURN Y if the P_PARTY_ID has at least one CUST_ACCT_ID related to it in HZ_MATCHED_PARIES_GT
-- Otherwise N
------------------------------------------------------------------------------------------------
( p_ctx_id     IN NUMBER,
  p_party_id   IN NUMBER,
  p_status     IN VARCHAR2)
RETURN VARCHAR2
IS
  CURSOR c1 IS
  SELECT 'Y'
    FROM hz_cust_accounts     a,
         hz_matched_parties_gt b
   WHERE a.party_id          = p_party_id
     AND a.cust_account_id   = -b.party_id
     AND b.search_context_id = p_ctx_id
     AND b.score             < 0
     AND DECODE(p_status, 'ALL','ALL',NVL(a.status,'A')) = p_status;
  ret VARCHAR2(1);
BEGIN
  OPEN c1;
  FETCH c1 INTO ret;
  IF c1%NOTFOUND THEN
    ret := 'N';
  END IF;
  CLOSE c1;
  RETURN ret;
END;

END;

/
