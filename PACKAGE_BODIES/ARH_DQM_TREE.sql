--------------------------------------------------------
--  DDL for Package Body ARH_DQM_TREE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARH_DQM_TREE" AS
/*$Header: ARHDQMTB.pls 120.4 2005/10/30 04:19:14 appldev noship $*/

ico_person    VARCHAR2(30) := 'afperson';
ico_party     VARCHAR2(30) := 'inv_item';
ico_account   VARCHAR2(30) := 'cscquicm';
ico_site      VARCHAR2(30) := 'asaddr';
ico_email     VARCHAR2(30) := 'afsend';
ico_phone     VARCHAR2(30) := 'asphone';
ico_primary   VARCHAR2(30) := 'afdispt';
ico_web       VARCHAR2(30) := 'aftrans';
ico_tlx       VARCHAR2(30) := 'cscscrip';



FUNCTION stypstr
( l  IN VARCHAR2)
RETURN VARCHAR2 IS
  pos NUMBER;
  ret VARCHAR2(2000);
BEGIN
  pos := INSTR(l, '*$#*');
  IF pos > 0 THEN
    ret := SUBSTR(l, pos + 4);
  ELSE
    ret := l;
  END IF;
  RETURN ret;
END;

FUNCTION atypstr
( l   IN VARCHAR2,
  typ IN VARCHAR2)
RETURN VARCHAR2 IS
BEGIN
  RETURN typ||'*$#*'||l;
END;

FUNCTION typostr
( l   IN VARCHAR2)
RETURN VARCHAR2 IS
  pos NUMBER;
  ret VARCHAR2(2000);
BEGIN
  pos := INSTR(l, '*$#*');
  IF pos > 0 THEN
    ret := SUBSTR(l,1,pos-1);
  ELSE
    ret := NULL;
  END IF;
  RETURN ret;
END;

FUNCTION r_score
( p_score        NUMBER,
  p_disp_percent VARCHAR2 DEFAULT 'Y')
RETURN VARCHAR2
IS
  ret   VARCHAR2(30);
BEGIN
  IF     p_score > 0 THEN
    IF p_disp_percent = 'Y' THEN
      ret := '  ('||to_char(p_score)||'%)';
    ELSE
      ret := '  ('||to_char(p_score)||')';
    END IF;
  ELSIF  p_score < 0 THEN
    IF p_disp_percent = 'Y' THEN
      ret := '  ('||to_char(-p_score)||'%)';
    ELSE
      ret := '  ('||to_char(-p_score)||')';
    END IF;
  ELSE
    ret := '';
  END IF;
  RETURN ret;
END;

FUNCTION AddList
( p_dsplist1     dsplist,
  p_dsplist2     dsplist)
RETURN dsplist
IS
  l_dsplist   dsplist;
  i           NUMBER;
  j           NUMBER;
BEGIN
  l_dsplist := erase_list;
  i  := p_dsplist1.COUNT;
  j  := p_dsplist2.COUNT;
  IF    i = 0 AND j = 0 THEN
    RETURN l_dsplist;
  ELSIF i = 0 THEN
   l_dsplist := p_dsplist2;
  ELSIF j = 0 THEN
   l_dsplist := p_dsplist1;
  ELSE
    l_dsplist := p_dsplist1;
    IF j > 0 THEN
      FOR k IN 1..j LOOP
        l_dsplist(i+k) := p_dsplist2(k);
      END LOOP;
    END IF;
  END IF;
  RETURN l_dsplist;
END;

FUNCTION dsplist_for_parties
(p_ctx_id               IN NUMBER,
 p_status               IN VARCHAR2 DEFAULT 'ALL',
 p_disp_percent         IN VARCHAR2 DEFAULT 'Y')
RETURN dsplist
IS
  CURSOR c_party_matched (i_ctx_id NUMBER, i_status  IN VARCHAR2) IS
  SELECT p.party_name,
         p.party_number,
         p.party_id,
         s.score
    FROM hz_matched_parties_gt s,
         hz_parties            p
   WHERE s.party_id                           = p.party_id
     AND s.search_context_id                  = i_ctx_id
     AND NVL(s.score,0)                       >= 0
--     AND DECODE(i_status,'ALL','ALL',NVL(p.status,'A'))= i_status
   ORDER BY s.score desc;
  l_rec      c_party_matched%ROWTYPE;
  i          NUMBER;
  j          NUMBER;
  init_depth NUMBER;
  init_ndata VARCHAR2(4000);
  l_dsplist  dsplist;
  tp_dsplist dsplist;
  resultlist dsplist;
  -- for error usage
  tmp_var              VARCHAR2(2000);
  tmp_var1             VARCHAR2(2000);
  already_exp          VARCHAR2(1) := 'N';
  l_score              VARCHAR2(30);
BEGIN
  i            := 0;
  j            := 0;
  init_depth   := 0;
  init_ndata   := NULL;

  OPEN c_party_matched(p_ctx_id, p_status);
  LOOP
    FETCH c_party_matched INTO l_rec;
    EXIT WHEN c_party_matched%NOTFOUND;
    i  :=  i + 1;
    IF i <= 5 THEN
      l_dsplist(i).state := 1;
    ELSE
      l_dsplist(i).state := -1;
    END IF;
    l_dsplist(i).depth := init_depth + 1;
    l_dsplist(i).label := nvl(l_rec.party_name||r_score(l_rec.score,p_disp_percent),'NULL');
    l_dsplist(i).icon  := ico_party;
    l_dsplist(i).ndata := atypstr('PARTY_ID:'||to_char(l_rec.party_id)||'@','PARTY');
    resultlist(resultlist.COUNT + 1) := l_dsplist(i);

    tp_dsplist := erase_list;
    tp_dsplist := Add_site_party(p_ctx_id,
                                 l_rec.party_id,
                                 p_status,
                                 l_dsplist(i));
    IF tp_dsplist.COUNT > 0  THEN
        resultlist := AddList( resultlist, tp_dsplist);
    END IF;

    tp_dsplist := erase_list;
    tp_dsplist := Add_Contact_party(p_ctx_id,
                                    l_rec.party_id,
                                    p_status,
                                    l_dsplist(i));
    IF tp_dsplist.COUNT > 0 THEN
      resultlist := AddList( resultlist, tp_dsplist);
    END IF;

    tp_dsplist := erase_list;
    tp_dsplist := Add_Ctp_to_Party(p_ctx_id      => p_ctx_id,
                                   p_party_id    => l_rec.party_id,
                                   p_status      => p_status,
                                   p_dsprec      => l_dsplist(i));

    IF tp_dsplist.COUNT > 0 THEN
      resultlist := AddList( resultlist, tp_dsplist);
    END IF;

  END LOOP;
  CLOSE c_party_matched;
  RETURN resultlist;
END;

FUNCTION Add_site_party
(p_ctx_id             IN     NUMBER,
 p_party_id           IN     NUMBER,
 p_status             IN     VARCHAR2 DEFAULT 'ALL',
 p_dsprec             IN     dsprec)
RETURN dsplist
IS
  CURSOR c_site_to_party (i_ctx_id    NUMBER,
                          i_party_id  NUMBER,
                          i_status    VARCHAR2,
                          prof_status VARCHAR2) IS
  SELECT gs.score,
         gs.party_site_id,
         l.address1,
         l.city,
         l.state,
         l.postal_code,
         s.identifying_address_flag
    FROM hz_matched_party_sites_gt gs,
         hz_party_sites          s,
         hz_locations            l
   WHERE gs.search_context_id                  = i_ctx_id
     AND gs.party_id                           = i_party_id
     AND NVL(gs.score,0)                       >= 0
     AND gs.party_site_id                      = s.party_site_id
     AND s.location_id                         = l.location_id
     AND DECODE(prof_status,'Y','A',NVL(s.status,'A')) = NVL(s.status,'A');
--     AND DECODE(i_status,'ALL','ALL',NVL(s.status,'A')) = i_status;
  l_rec      c_site_to_party%ROWTYPE;
  i          NUMBER;
  l_dsplist  dsplist;
  init_depth NUMBER;
  init_ndata VARCHAR2(2000);
  tp_dsplist dsplist;
  resultlist dsplist;
  l_score    VARCHAR2(30);
  -- for error usage
  tmp_var              VARCHAR2(2000);
  tmp_var1             VARCHAR2(2000);
  --BUG#3666792
  l_site_status        VARCHAR2(10);
BEGIN
  l_site_status := NVL(fnd_profile.value('HZ_SHOW_ONLY_ACTIVE_ADDRESSES'),'N');

  i := 0;
  init_depth   := p_dsprec.depth;
  init_ndata   := p_dsprec.ndata;

  OPEN c_site_to_party(p_ctx_id, p_party_id, p_status, l_site_status);
  LOOP
    FETCH c_site_to_party INTO l_rec;
    EXIT WHEN c_site_to_party%NOTFOUND;
    i  :=  i + 1;
    l_dsplist(i).state := 0;
    l_dsplist(i).depth := init_depth + 1;
    l_dsplist(i).label := nvl(l_rec.address1||' - '||l_rec.city||' '||l_rec.state||' '||l_rec.postal_code,'NULL');

    IF l_rec.identifying_address_flag = 'Y' THEN
      l_dsplist(i).icon  := ico_primary;
    ELSE
      l_dsplist(i).icon  := ico_site;
    END IF;

    l_dsplist(i).ndata := atypstr(stypstr(p_dsprec.ndata)||'PARTY_SITE_ID:'||to_char(l_rec.party_site_id)||'@','PARTY_SITE');
    resultlist(resultlist.COUNT + 1) := l_dsplist(i);

    tp_dsplist := erase_list;
    tp_dsplist := Add_Contact_to_site(p_ctx_id,
                                      p_party_id,
                                      l_rec.party_site_id,
                                      p_status,
                                      l_dsplist(i));
    IF tp_dsplist.COUNT > 0 THEN
      resultlist(resultlist.COUNT).state := 1;
      resultlist := AddList( resultlist, tp_dsplist);
    END IF;

--HYU Manque Add Contact Point to Party Site
    tp_dsplist := erase_list;
    tp_dsplist := Add_Ctp_to_Party_Site(p_ctx_id,
                                        p_party_id,
                                        l_rec.party_site_id,
                                        p_status,
                                        l_dsplist(i));
    IF tp_dsplist.COUNT > 0 THEN
      resultlist(resultlist.COUNT).state := 1;
      resultlist := AddList( resultlist, tp_dsplist);
    END IF;

  END LOOP;
  CLOSE c_site_to_party;
  RETURN resultlist;
END;

FUNCTION Add_Contact_party
(p_ctx_id             IN     NUMBER,
 p_party_id           IN     NUMBER,
 p_status             IN     VARCHAR2 DEFAULT 'ALL',
 p_dsprec             IN     dsprec)
RETURN dsplist
IS
  cursor c_contact_to_party (i_ctx_id IN NUMBER, i_party_id IN NUMBER, i_status IN VARCHAR2) is
  select a.score,
         o.org_contact_id,
         r.party_id           rel_pty_id,
         r.relationship_code  rel_code,
         p.party_id           person_id,
         p.party_name,
         p.party_number
    from hz_matched_contacts_gt  a,
         hz_org_contacts         o,
         hz_relationships        r,
         hz_parties              p
   where a.search_context_id                   = i_ctx_id
     and a.party_id                            = i_party_id
     and a.org_contact_id                      = o.org_contact_id
     and nvl(a.score,0)                        >= 0
     and o.party_site_id                       IS NULL
     and o.party_relationship_id               = r.relationship_id
     and r.directional_flag                    = 'B'
     and r.object_id                           = p.party_id;
--     and DECODE(p_status,'ALL','ALL',NVL(o.status,'A')) = p_status;
  l_rec      c_contact_to_party%ROWTYPE;
  i          NUMBER;
  l_dsplist  dsplist;
  init_depth NUMBER;
  init_ndata VARCHAR2(2000);
  tp_dsplist dsplist;
  resultlist dsplist;
  -- for error usage
  tmp_var              VARCHAR2(2000);
  tmp_var1             VARCHAR2(2000);
BEGIN
  i := 0;
  init_depth   := p_dsprec.depth;
  init_ndata   := p_dsprec.ndata;
  OPEN c_contact_to_party(p_ctx_id, p_party_id, p_status);
  LOOP
    FETCH c_contact_to_party INTO l_rec;
    EXIT WHEN c_contact_to_party%NOTFOUND;
    i  :=  i + 1;
    l_dsplist(i).state := 0;
    l_dsplist(i).depth := init_depth + 1;
    l_dsplist(i).label := nvl(l_rec.party_name,'NULL');
    l_dsplist(i).icon  := ico_person;
    l_dsplist(i).ndata := atypstr(stypstr(init_ndata)||'ORG_CONTACT_ID:'||to_char(l_rec.org_contact_id)||'@REL_PTY_ID:'||to_char(l_rec.rel_pty_id)||'@PERSON_ID:'||to_char(l_rec.person_id)||'@','ORG_CONTACT');
    resultlist(resultlist.COUNT + 1) := l_dsplist(i);
    tp_dsplist := erase_list;
    tp_dsplist := Add_Ctp_to_Party(p_ctx_id,
                                   p_party_id,
                                   l_rec.rel_pty_id,
                                   p_status,
                                   l_dsplist(i));
    IF tp_dsplist.COUNT > 0 THEN
      resultlist(resultlist.COUNT).state := 1;
      resultlist := AddList( resultlist, tp_dsplist);
    ELSE
--HYU 2103
      resultlist(resultlist.COUNT).state := 0;
    END IF;
  END LOOP;
  CLOSE c_contact_to_party;
  RETURN resultlist;
END;

FUNCTION Add_Contact_to_site
( p_ctx_id        NUMBER,
  p_party_id      NUMBER,
  p_party_site_id NUMBER,
  p_status        IN VARCHAR2 DEFAULT 'ALL',
  p_dsprec        dsprec)
RETURN dsplist
IS
  CURSOR c_contact_to_site(  i_ctx_id        NUMBER,
                             i_party_id      NUMBER,
                             i_party_site_id NUMBER,
                             i_status        VARCHAR2) IS
  SELECT gc.org_contact_id            ,
         gc.score                     ,
         p.party_name                 ,
         p.party_number               ,
         p.party_id          person_id,
         r.party_id          rel_pty_id,
         r.relationship_code rel_code
    FROM hz_matched_contacts_gt  gc,
         hz_org_contacts         c,
         hz_relationships        r,
         hz_parties              p
   WHERE gc.search_context_id  = i_ctx_id
     AND gc.party_id           = i_party_id
     AND gc.org_contact_id     = c.org_contact_id
     AND NVL(gc.score,0)       >= 0
     AND c.party_site_id       = i_party_site_id
     AND c.party_relationship_id = r.relationship_id
     AND r.directional_flag    = 'B'
     AND r.object_id           = p.party_id;
--     AND DECODE(i_status, 'ALL', 'ALL', NVL(c.status,'A')) = i_status;
  l_rec      c_contact_to_site%ROWTYPE;
  i          NUMBER;
  l_dsplist  dsplist;
  init_depth NUMBER;
  init_ndata VARCHAR2(2000);
  tp_dsplist dsplist;
  resultlist dsplist;
  l_score              VARCHAR2(30);
  -- for error usage
  tmp_var              VARCHAR2(2000);
  tmp_var1             VARCHAR2(2000);
BEGIN
  i            := 0;
  init_depth   := p_dsprec.depth;
  init_ndata   := p_dsprec.ndata;
  OPEN c_contact_to_site(p_ctx_id, p_party_id, p_party_site_id, p_status);
  LOOP
    FETCH c_contact_to_site INTO l_rec;
    EXIT WHEN c_contact_to_site%NOTFOUND;
    i  :=  i + 1;
    l_dsplist(i).state := 0;
    l_dsplist(i).depth := init_depth + 1;
    l_dsplist(i).label := nvl(l_rec.party_name,'NULL');
    l_dsplist(i).icon  := ico_person;
    l_dsplist(i).ndata := atypstr(stypstr(init_ndata)||'ORG_CONTACT_ID:'||to_char(l_rec.org_contact_id)||'@PERSON_ID:'||to_char(l_rec.person_id)||'@REL_PTY_ID:'||to_char(l_rec.rel_pty_id)||'@','ORG_CONTACT');
    resultlist(resultlist.COUNT + 1) := l_dsplist(i);
    tp_dsplist := erase_list;

    tp_dsplist := Add_Ctp_to_Party(p_ctx_id,
                                   p_party_id,
                                   l_rec.rel_pty_id,
                                   p_status,
                                   l_dsplist(i));

    IF tp_dsplist.COUNT > 0 THEN
      resultlist(resultlist.COUNT).state := 1;
      resultlist := AddList( resultlist, tp_dsplist);
    END IF;
  END LOOP;
  CLOSE c_contact_to_site;
  RETURN resultlist;
END;

FUNCTION Add_Ctp_to_Party
(p_ctx_id           IN  NUMBER,
 p_party_id         IN  NUMBER,
 p_rel_pty_id       IN  NUMBER DEFAULT NULL,
 p_status           IN  VARCHAR2 DEFAULT 'ALL',
 p_dsprec           IN  dsprec)
RETURN dsplist
IS
  CURSOR c_ctp_to_party(i_ctx_id     NUMBER,
                        i_party_id   NUMBER,
                        i_rel_pty_id NUMBER,
                        i_status     VARCHAR2) IS
  SELECT ctpt.contact_point_type,
         ctpt.contact_point_id,
         gcpt.score,
         decode(ctpt.contact_point_type, 'EMAIL', ctpt.email_address,
                                         'PHONE', DECODE(ctpt.phone_area_code,NULL,NULL,ctpt.phone_area_code||'-')||ctpt.phone_number,
                                         'TELEX', ctpt.telex_number,
                                         'WEB',   ctpt.url ) ad
    FROM hz_matched_cpts_gt  gcpt,
         hz_contact_points   ctpt
   WHERE gcpt.search_context_id                      = i_ctx_id
     AND gcpt.party_id                               = i_party_id
     AND NVL(gcpt.score,0)                           >= 0
     AND ctpt.owner_table_name                       = 'HZ_PARTIES'
     AND ctpt.owner_table_id                         = i_rel_pty_id
     AND gcpt.contact_point_id                       = ctpt.contact_point_id;
--     AND DECODE(i_status, 'ALL', 'ALL', NVL(ctpt.status,'A')) = i_status;

  CURSOR c_ctp_to_party_dir(i_ctx_id   NUMBER,
                            i_party_id NUMBER,
                            i_status   VARCHAR2) IS
  SELECT ctpt.contact_point_type,
         ctpt.contact_point_id,
         gcpt.score,
         decode(ctpt.contact_point_type, 'EMAIL', ctpt.email_address,
                                         'PHONE', DECODE(ctpt.phone_area_code,NULL,NULL,ctpt.phone_area_code||'-')||ctpt.phone_number,
                                         'TLX'  , ctpt.telex_number,
                                         'WEB'  , ctpt.url ) ad
    FROM hz_matched_cpts_gt  gcpt,
         hz_contact_points   ctpt
   WHERE gcpt.search_context_id                      = i_ctx_id
     AND gcpt.party_id                               = i_party_id
     AND NVL(gcpt.score,0)                           >= 0
     AND ctpt.owner_table_name                       = 'HZ_PARTIES'
     AND ctpt.owner_table_id                         = i_party_id
     AND gcpt.contact_point_id                       = ctpt.contact_point_id;
--     AND DECODE(i_status, 'ALL', 'ALL', NVL(ctpt.status,'A')) = i_status;

  l_rec      c_ctp_to_party%ROWTYPE;
  i          NUMBER;
  l_dsplist  dsplist;
  init_depth NUMBER;
  init_ndata VARCHAR2(2000);
  l_score    VARCHAR2(30);
BEGIN
  i            := 0;
  init_depth   := p_dsprec.depth;
  init_ndata   := p_dsprec.ndata;
  IF p_rel_pty_id IS NOT NULL THEN
    OPEN c_ctp_to_party(p_ctx_id  ,  p_party_id, p_rel_pty_id, p_status);
    LOOP
      FETCH c_ctp_to_party INTO l_rec;
      EXIT WHEN c_ctp_to_party%NOTFOUND;
      i  :=  i + 1;
      l_dsplist(i).state := 0;
      l_dsplist(i).depth := init_depth + 1;
      l_dsplist(i).label := nvl(l_rec.ad,'NULL');

      IF    l_rec.contact_point_type = 'EMAIL' THEN  l_dsplist(i).icon  := ico_email;
      ELSIF l_rec.contact_point_type = 'PHONE' THEN  l_dsplist(i).icon  := ico_phone;
      ELSIF l_rec.contact_point_type = 'TLX'   THEN  l_dsplist(i).icon  := ico_tlx;
      ELSIF l_rec.contact_point_type = 'WEB'   THEN  l_dsplist(i).icon  := ico_web;
      END IF;

      l_dsplist(i).ndata := atypstr(stypstr(init_ndata)||'CONTACT_POINT_ID:'||TO_CHAR(l_rec.contact_point_id)||'@','CONTACT_POINT');
    END LOOP;
    CLOSE c_ctp_to_party;
  ELSIF p_rel_pty_id IS NULL THEN
    OPEN c_ctp_to_party_dir(p_ctx_id  ,  p_party_id, p_status);
    LOOP
      FETCH c_ctp_to_party_dir INTO l_rec;
      EXIT WHEN c_ctp_to_party_dir%NOTFOUND;
      i  :=  i + 1;
      l_dsplist(i).state := 0;
      l_dsplist(i).depth := init_depth + 1;
      l_dsplist(i).label := nvl(l_rec.ad,'NULL');

      IF    l_rec.contact_point_type = 'EMAIL' THEN  l_dsplist(i).icon  := ico_email;
      ELSIF l_rec.contact_point_type = 'PHONE' THEN  l_dsplist(i).icon  := ico_phone;
      ELSIF l_rec.contact_point_type = 'TLX'   THEN  l_dsplist(i).icon  := ico_tlx;
      ELSIF l_rec.contact_point_type = 'WEB'   THEN  l_dsplist(i).icon  := ico_web;
      END IF;

      l_dsplist(i).ndata := atypstr(stypstr(init_ndata)||'CONTACT_POINT_ID:'||TO_CHAR(l_rec.contact_point_id)||'@','CONTACT_POINT');
    END LOOP;
    CLOSE c_ctp_to_party_dir;
  END IF;
  RETURN l_dsplist;
END;

--HYU
FUNCTION Add_Ctp_to_Party_Site
(p_ctx_id           IN  NUMBER,
 p_party_id         IN  NUMBER,
 p_party_site_id    IN  NUMBER,
 p_status           IN  VARCHAR2 DEFAULT 'ALL',
 p_dsprec           IN  dsprec)
RETURN dsplist
IS
  CURSOR c1(i_ctx_id      NUMBER,
            i_party_id    NUMBER,
            i_pty_site_id NUMBER,
            i_status      VARCHAR2) IS
  SELECT ctpt.contact_point_type,
         ctpt.contact_point_id,
         gcpt.score,
         decode(ctpt.contact_point_type, 'EMAIL', ctpt.email_address,
                                         'PHONE', DECODE(ctpt.phone_area_code,NULL,NULL,ctpt.phone_area_code||'-')||ctpt.phone_number,
                                         'TELEX', ctpt.telex_number,
                                         'WEB',   ctpt.url ) ad
    FROM hz_matched_cpts_gt  gcpt,
         hz_contact_points   ctpt
   WHERE gcpt.search_context_id                      = i_ctx_id
     AND gcpt.party_id                               = i_party_id
     AND NVL(gcpt.score,0)                           >= 0
     AND ctpt.owner_table_name                       = 'HZ_PARTY_SITES'
     AND ctpt.owner_table_id                         = i_pty_site_id
     AND gcpt.contact_point_id                       = ctpt.contact_point_id;
--     AND DECODE(i_status, 'ALL', 'ALL', NVL(ctpt.status,'A')) = i_status;
  l_rec      c1%ROWTYPE;
  i          NUMBER;
  l_dsplist  dsplist;
  init_depth NUMBER;
  init_ndata VARCHAR2(2000);
  l_score    VARCHAR2(30);
BEGIN
  i            := 0;
  init_depth   := p_dsprec.depth;
  init_ndata   := p_dsprec.ndata;
  OPEN c1(p_ctx_id,  p_party_id, p_party_site_id, p_status);
    LOOP
      FETCH c1 INTO l_rec;
      EXIT WHEN c1%NOTFOUND;
      i  :=  i + 1;
      l_dsplist(i).state := 0;
      l_dsplist(i).depth := init_depth + 1;
      l_dsplist(i).label := nvl(l_rec.ad,'NULL');

      IF    l_rec.contact_point_type = 'EMAIL' THEN  l_dsplist(i).icon  := ico_email;
      ELSIF l_rec.contact_point_type = 'PHONE' THEN  l_dsplist(i).icon  := ico_phone;
      ELSIF l_rec.contact_point_type = 'TLX'   THEN  l_dsplist(i).icon  := ico_tlx;
      ELSIF l_rec.contact_point_type = 'WEB'   THEN  l_dsplist(i).icon  := ico_web;
      END IF;

      l_dsplist(i).ndata := atypstr(stypstr(init_ndata)||'CONTACT_POINT_ID:'||TO_CHAR(l_rec.contact_point_id)||'@','CONTACT_POINT');
    END LOOP;
    CLOSE c1;
  RETURN l_dsplist;
END;



----------090202
FUNCTION dsp_for_party_pty_accts
(p_ctx_id       IN NUMBER,
 p_cur_all      IN VARCHAR2 DEFAULT 'ALL',
 p_status       IN VARCHAR2 DEFAULT 'ALL',
 p_disp_percent IN VARCHAR2 DEFAULT 'Y')
RETURN dsplist
IS
  CURSOR c_party_matched (i_ctx_id NUMBER, i_status VARCHAR2) IS
  SELECT distinct p.party_name,
         p.party_number,
         p.party_id,
         s.score
    FROM hz_matched_parties_gt s,
         hz_parties            p
         /*hz_matched_parties_gt ca1  Bug2678267 Commented to avoid cartesian join pblm */
   WHERE s.party_id                               = p.party_id
     AND s.search_context_id                      = i_ctx_id
     AND NVL(s.score,0)                           >= 0
--     AND DECODE(i_status, 'ALL', 'ALL', NVL(p.status,'A')) = i_status
   ORDER BY s.score desc;

  l_rec      c_party_matched%ROWTYPE;
  i          NUMBER;
  j          NUMBER;
  init_depth NUMBER;
  init_ndata VARCHAR2(4000);
  l_dsplist  dsplist;
  tp_dsplist dsplist;
  resultlist dsplist;
  -- for error usage
  tmp_var              VARCHAR2(2000);
  tmp_var1             VARCHAR2(2000);
  already_exp          VARCHAR2(1) := 'N';
  l_score              VARCHAR2(30);

BEGIN
  i            := 0;
  j            := 0;
  init_depth   := 0;
  init_ndata   := NULL;

  OPEN c_party_matched(p_ctx_id, p_status);
  LOOP
    FETCH c_party_matched INTO l_rec;
    EXIT WHEN c_party_matched%NOTFOUND;
    i  :=  i + 1;
    IF i <= 5 THEN
      l_dsplist(i).state := 1;
    ELSE
      l_dsplist(i).state := -1;
    END IF;
    l_dsplist(i).depth := init_depth + 1;
    l_dsplist(i).label := nvl(l_rec.party_name||r_score(l_rec.score,p_disp_percent),'NULL');
    l_dsplist(i).icon  := ico_party;
    l_dsplist(i).ndata := atypstr('PARTY_ID:'||to_char(l_rec.party_id)||'@','PARTY');
    resultlist(resultlist.COUNT + 1) := l_dsplist(i);
    tp_dsplist := erase_list;
    tp_dsplist := add_acct_party(p_ctx_id,
                                 l_rec.party_id,
                                 p_cur_all,
                                 p_status,
                                 l_dsplist(i));
    IF tp_dsplist.COUNT > 0  THEN
        resultlist := AddList( resultlist, tp_dsplist);
--{HYU
    ELSE
      l_dsplist(i).state := 0;
--}
    END IF;
  END LOOP;
  CLOSE c_party_matched;
  RETURN resultlist;
END;


FUNCTION dsp_for_party_accts
(p_ctx_id       IN NUMBER,
 p_cur_all      IN VARCHAR2 DEFAULT 'ALL',
 p_status       IN VARCHAR2 DEFAULT 'ALL',
 p_disp_percent IN VARCHAR2 DEFAULT 'Y')
RETURN dsplist
IS
  CURSOR c_party_matched (i_ctx_id NUMBER, i_status VARCHAR2) IS
  SELECT distinct p.party_name,
         p.party_number,
         p.party_id,
         s.score
    FROM hz_matched_parties_gt s,
         hz_parties            p,
         hz_matched_parties_gt ca1,
         hz_cust_accounts      ca2
   WHERE s.party_id                               = p.party_id
     AND s.search_context_id                      = i_ctx_id
     AND NVL(s.score,0)                           >= 0
--     AND DECODE(i_status, 'ALL', 'ALL', NVL(p.status,'A')) = i_status
     AND s.party_id                               = ca2.party_id
     AND ca1.score                                < 0
     AND ca1.search_context_id                    = i_ctx_id
     AND ca2.cust_account_id                      = -ca1.party_id
     AND DECODE(i_status, 'ALL', 'ALL', NVL(ca2.status,'A')) = i_status
   ORDER BY s.score desc;

  l_rec      c_party_matched%ROWTYPE;
  i          NUMBER;
  j          NUMBER;
  init_depth NUMBER;
  init_ndata VARCHAR2(4000);
  l_dsplist  dsplist;
  tp_dsplist dsplist;
  resultlist dsplist;
  -- for error usage
  tmp_var              VARCHAR2(2000);
  tmp_var1             VARCHAR2(2000);
  already_exp          VARCHAR2(1) := 'N';
  l_score              VARCHAR2(30);

BEGIN
  i            := 0;
  j            := 0;
  init_depth   := 0;
  init_ndata   := NULL;

  OPEN c_party_matched(p_ctx_id, p_status);
  LOOP
    FETCH c_party_matched INTO l_rec;
    EXIT WHEN c_party_matched%NOTFOUND;
    i  :=  i + 1;
    IF i <= 5 THEN
      l_dsplist(i).state := 1;
    ELSE
      l_dsplist(i).state := -1;
    END IF;
    l_dsplist(i).depth := init_depth + 1;
    l_dsplist(i).label := nvl(l_rec.party_name||r_score(l_rec.score,p_disp_percent),'NULL');
    l_dsplist(i).icon  := ico_party;
    l_dsplist(i).ndata := atypstr('PARTY_ID:'||to_char(l_rec.party_id)||'@','PARTY');
    resultlist(resultlist.COUNT + 1) := l_dsplist(i);
    tp_dsplist := erase_list;
    tp_dsplist := add_acct_party(p_ctx_id,
                                 l_rec.party_id,
                                 p_cur_all,
                                 p_status,
                                 l_dsplist(i));
    IF tp_dsplist.COUNT > 0  THEN
        resultlist := AddList( resultlist, tp_dsplist);
    END IF;
  END LOOP;
  CLOSE c_party_matched;
  RETURN resultlist;
END;


---

FUNCTION add_acct_party
(p_ctx_id      IN NUMBER,
 p_party_id    IN NUMBER,
 p_cur_all     IN VARCHAR2 DEFAULT 'ALL',
 p_status      IN VARCHAR2 DEFAULT 'ALL',
 p_dsprec      IN dsprec)
RETURN dsplist
IS

--HYU
  CURSOR c_custaccts(i_ctx_id   NUMBER,
                     i_party_id NUMBER,
                     i_status   VARCHAR2) IS
  SELECT distinct a.cust_account_id,
         a.account_number,
         a.customer_class_code,
         a.account_name,
         p.party_name,
         p.party_number,
         p.party_id,
         s.score
    FROM hz_cust_accounts      a,
         hz_matched_parties_gt s,
         hz_parties            p
   WHERE a.party_id          =  i_party_id
     AND a.cust_account_id   =  -s.party_id
     AND s.score             <  0
     AND s.search_context_id = i_ctx_id
     AND a.party_id          = p.party_id
     AND DECODE(i_status, 'ALL', 'ALL', NVL(a.status,'A')) = i_status
   ORDER BY s.score asc;

  l_rec      c_custaccts%ROWTYPE;
  i          NUMBER;
  j          NUMBER;
  init_depth NUMBER;
  init_ndata VARCHAR2(4000);
  l_dsplist  dsplist;
  tp_dsplist dsplist;
  resultlist dsplist;
  -- for error usage
  tmp_var              VARCHAR2(2000);
  tmp_var1             VARCHAR2(2000);
  already_exp          VARCHAR2(1) := 'N';
  l_score              VARCHAR2(30);

BEGIN
  i  := 0;
  init_depth   := p_dsprec.depth;
  init_ndata   := p_dsprec.ndata;

  OPEN c_custaccts(p_ctx_id, p_party_id, p_status);
  LOOP
    FETCH c_custaccts INTO l_rec;
    EXIT WHEN c_custaccts%NOTFOUND;
    i  :=  i + 1;

    l_dsplist(i).depth := init_depth + 1;

    IF l_rec.account_name IS NULL THEN
      l_dsplist(i).label :=nvl(l_rec.party_name||'-'||l_rec.account_number,'NULL');
    ELSE
      l_dsplist(i).label :=nvl(l_rec.account_name||'-'||l_rec.account_number,'NULL');
    END IF;
--HYU{
    l_dsplist(i).state  := 1;
    j := i;
--}
    l_dsplist(i).icon  := ico_account;
    l_dsplist(i).ndata := atypstr(stypstr(init_ndata)||'CUST_ACCOUNT_ID:'||to_char(l_rec.cust_account_id)||'@','ACCOUNT');
    resultlist(resultlist.COUNT + 1) := l_dsplist(i);
--HYU
    tp_dsplist := erase_list;
    tp_dsplist := Add_site_acct(p_ctx_id,
                                p_party_id,
                                l_rec.cust_account_id,
                                p_cur_all,
                                p_status,
                                l_dsplist(i));
    IF tp_dsplist.COUNT > 0  THEN
        l_dsplist(i).state := 1;
        resultlist := AddList( resultlist, tp_dsplist);
--{HYU 1903
    ELSE
        l_dsplist(j).state := 0;
--}
    END IF;

    tp_dsplist := erase_list;
    tp_dsplist := Add_Contact_Acct(p_ctx_id,
                                   p_party_id,
                                   l_rec.cust_account_id,
                                   p_status,
                                   l_dsplist(i));

    IF tp_dsplist.COUNT > 0 THEN
      resultlist := AddList( resultlist, tp_dsplist);
    END IF;
--HYU
    tp_dsplist := erase_list;
    tp_dsplist := Add_Ctp_to_Party(p_ctx_id  => p_ctx_id,
                                   p_party_id=> l_rec.party_id,
                                   p_status  => p_status,
                                   p_dsprec  => l_dsplist(i));
    IF tp_dsplist.COUNT > 0 THEN
      resultlist(resultlist.COUNT).state := 1;
      resultlist := AddList( resultlist, tp_dsplist);
    ELSE
--HYU2103
      resultlist(resultlist.COUNT).state := 0;
    END IF;

  END LOOP;
  CLOSE c_custaccts;
  RETURN resultlist;
END;


FUNCTION Add_site_acct
(p_ctx_id             IN     NUMBER,
 p_party_id           IN     NUMBER,
 p_cust_acct_id       IN     NUMBER,
 p_cur_all            IN     VARCHAR2  DEFAULT 'ALL',
 p_status             IN     VARCHAR2  DEFAULT 'ALL',
 p_dsprec             IN     dsprec)
RETURN dsplist
IS
  TYPE nrc  IS REF CURSOR;
  cv   nrc;
  l_score_n           NUMBER;
  l_party_id          NUMBER;
  l_party_site_id     NUMBER;
  l_cust_account_id   NUMBER;
  l_cust_acct_site_id NUMBER;
  l_address1          VARCHAR2(240);
  l_city              VARCHAR2(60);
  l_state             VARCHAR2(60);
  l_postal_code       VARCHAR2(60);
  l_iden_address_flag VARCHAR2(30);
  i          NUMBER;
  l_dsplist  dsplist;
  init_depth NUMBER;
  init_ndata VARCHAR2(2000);
  tp_dsplist dsplist;
  resultlist dsplist;
  l_score    VARCHAR2(30);
  -- for error usage
  tmp_var              VARCHAR2(2000);
  tmp_var1             VARCHAR2(2000);
  --BUG#3666792
  l_active_site        VARCHAR2(10);
BEGIN
  i := 0;
  init_depth   := p_dsprec.depth;
  init_ndata   := p_dsprec.ndata;

  l_active_site := NVL(fnd_profile.value('HZ_SHOW_ONLY_ACTIVE_ADDRESSES'),'N');

    IF p_cur_all = 'ALL' THEN

    OPEN cv FOR
    SELECT distinct gs.score,
           ps.party_id,
           ps.party_site_id,
           a.cust_account_id,
           a.cust_acct_site_id,
           l.address1,
           l.city,
           l.state,
           l.postal_code,
           ps.identifying_address_flag
      FROM hz_matched_party_sites_gt gs,
           hz_cust_acct_sites_all    a,
           hz_party_sites            ps,
           hz_locations              l
     WHERE gs.search_context_id                  = p_ctx_id
       AND gs.score                              < 0
       AND -gs.party_id                          = p_cust_acct_id
       AND -gs.party_site_id                     = a.cust_acct_site_id
       AND a.party_site_id                       = ps.party_site_id
       AND ps.location_id                        = l.location_id
       AND DECODE(l_active_site, 'Y', 'A', NVL(a.status,'A')) = NVL(a.status,'A');
--       AND DECODE(p_status,'ALL','ALL',NVL(a.status,'A')) = p_status;

   ELSIF p_cur_all = 'CUR' THEN
    OPEN cv FOR
    SELECT distinct gs.score,
           ps.party_id,
           ps.party_site_id,
           a.cust_account_id,
           a.cust_acct_site_id,
           l.address1,
           l.city,
           l.state,
           l.postal_code,
           ps.identifying_address_flag
      FROM hz_matched_party_sites_gt gs,
           hz_cust_acct_sites        a,
           hz_party_sites            ps,
           hz_locations              l
     WHERE gs.search_context_id                  = p_ctx_id
       AND gs.score                              < 0
       AND -gs.party_id                          = p_cust_acct_id
       AND -gs.party_site_id                     = a.cust_acct_site_id
       AND a.party_site_id                       = ps.party_site_id
       AND ps.location_id                        = l.location_id
       AND DECODE(l_active_site, 'Y', 'A', NVL(a.status,'A')) = NVL(a.status,'A');
--       AND DECODE(p_status,'ALL','ALL',NVL(a.status,'A')) = p_status;

  END IF;

  IF cv%ISOPEN THEN
    LOOP
      FETCH cv INTO   l_score_n          ,
                      l_party_id         ,
                      l_party_site_id    ,
                      l_cust_account_id  ,
                      l_cust_acct_site_id,
                      l_address1         ,
                      l_city             ,
                      l_state            ,
                      l_postal_code      ,
                      l_iden_address_flag;
      EXIT WHEN cv%NOTFOUND;
      i  :=  i + 1;
      l_dsplist(i).state := 0;
      l_dsplist(i).depth := init_depth + 1;
      l_dsplist(i).label := nvl(l_address1||' - '||l_city||' '||l_state||' '||l_postal_code,'NULL');
 --     l_dsplist(i).icon  := ico_site;

      IF l_iden_address_flag = 'Y' THEN
        l_dsplist(i).icon  := ico_primary;
      ELSE
        l_dsplist(i).icon  := ico_site;
      END IF;

      l_dsplist(i).ndata := atypstr(stypstr(init_ndata)||'PARTY_SITE_ID:'||to_char(l_party_site_id)||'@ACCT_SITE_ID:'||TO_CHAR(l_cust_acct_site_id)||'@','CUST_ACCT_SITE');
      resultlist(resultlist.COUNT + 1) := l_dsplist(i);

      tp_dsplist := erase_list;
      tp_dsplist := Add_Contact_to_acct_site(p_ctx_id,
                                             p_party_id,
                                             l_cust_account_id,
                                             l_cust_acct_site_id,
                                             p_cur_all,
                                             p_status,
                                             l_dsplist(i));

      IF tp_dsplist.COUNT > 0 THEN
        resultlist(resultlist.COUNT).state := 1;
        resultlist := AddList( resultlist, tp_dsplist);
      END IF;
--HYU
      tp_dsplist := erase_list;
      tp_dsplist := Add_Ctp_to_Party_Site(p_ctx_id,
                                          p_party_id,
                                          l_party_site_id,
                                          p_status,
                                          l_dsplist(i));
      IF tp_dsplist.COUNT > 0 THEN
        resultlist(resultlist.COUNT).state := 1;
        resultlist := AddList( resultlist, tp_dsplist);
      END IF;

    END LOOP;
    CLOSE cv;
  END IF;
  RETURN resultlist;
END;


--HYU


FUNCTION Add_Contact_Acct
(p_ctx_id             IN     NUMBER,
 p_party_id           IN     NUMBER,
 p_cust_acct_id       IN     NUMBER,
 p_status             IN     VARCHAR2 DEFAULT 'ALL',
 p_dsprec             IN     dsprec)
RETURN dsplist
IS
--HYU
  cursor c_contact_to_acct (i_ctx_id IN NUMBER, i_cust_acct_id IN NUMBER) is
  select distinct a.score,
         r.party_id           rel_pty_id,
         r.relationship_code  rel_code,
         ro.cust_account_role_id,
         p.party_id           person_id,
         p.party_name,
         p.party_number,
         o.org_contact_id
    from hz_matched_contacts_gt  a,
         hz_relationships        r,
         hz_parties              p,
         hz_cust_account_roles   ro,
         hz_org_contacts         o
   where a.search_context_id = i_ctx_id
     and a.score             < 0
     and -a.party_id         = i_cust_acct_id
     and -a.org_contact_id   = ro.cust_account_role_id
     and ro.party_id         = r.party_id
     and r.relationship_id   = o.party_relationship_id
     and r.directional_flag  = 'B'
     and r.object_id         = p.party_id
     and ro.cust_acct_site_id IS NULL;
--     and DECODE(p_status,'ALL','ALL', NVL(ro.status,'A')) = p_status;

  l_rec      c_contact_to_acct%ROWTYPE;
  i          NUMBER;
  l_dsplist  dsplist;
  init_depth NUMBER;
  init_ndata VARCHAR2(2000);
  tp_dsplist dsplist;
  resultlist dsplist;
  -- for error usage
  tmp_var              VARCHAR2(2000);
  tmp_var1             VARCHAR2(2000);

BEGIN
  i := 0;
  init_depth   := p_dsprec.depth;
  init_ndata   := p_dsprec.ndata;

  OPEN c_contact_to_acct(p_ctx_id,
                         p_cust_acct_id);
  LOOP
    FETCH c_contact_to_acct INTO l_rec;
    EXIT WHEN c_contact_to_acct%NOTFOUND;
    i  :=  i + 1;
    l_dsplist(i).state := 0;
    l_dsplist(i).depth := init_depth + 1;
    l_dsplist(i).label := nvl(l_rec.party_name,'NULL');
    l_dsplist(i).icon  := ico_person;
    l_dsplist(i).ndata := atypstr(stypstr(init_ndata)||
                          'CUST_ACCOUNT_ROLE_ID:'||
                          to_char(l_rec.cust_account_role_id)||
                          '@ORG_CONTACT_ID:'||to_char(l_rec.org_contact_id)||
                          '@REL_PTY_ID:'||to_char(l_rec.rel_pty_id)||
                          '@PERSON_ID:'||to_char(l_rec.person_id)||'@','CUST_ACCOUNT_ROLE');
    resultlist(resultlist.COUNT + 1) := l_dsplist(i);
    tp_dsplist := erase_list;
    tp_dsplist := Add_Ctp_to_Party(p_ctx_id,
                                   p_party_id,
                                   l_rec.rel_pty_id,
                                   p_status,
                                   l_dsplist(i));
    IF tp_dsplist.COUNT > 0 THEN
      resultlist(resultlist.COUNT).state := 1;
      resultlist := AddList( resultlist, tp_dsplist);
    END IF;

  END LOOP;
  CLOSE c_contact_to_acct;
  RETURN resultlist;

END;


FUNCTION Add_Contact_to_acct_site
( p_ctx_id        IN NUMBER,
  p_party_id      IN NUMBER,
  p_cust_acct_id  IN NUMBER,
  p_acct_site_id  IN NUMBER,
  p_cur_all       IN VARCHAR2,
  p_status        IN VARCHAR2 DEFAULT 'ALL',
  p_dsprec        IN dsprec)
RETURN dsplist
IS
  CURSOR c_contact_to_site(  i_ctx_id        NUMBER,
                             i_cust_acct_id  NUMBER,
                             i_acct_site_id  NUMBER,
                             i_status        VARCHAR2) IS
  SELECT distinct gc.score                     ,
         p.party_name                 ,
         p.party_number               ,
         p.party_id          person_id,
         ro.cust_account_role_id      ,
         r.party_id          rel_pty_id,
         r.relationship_code rel_code  ,
         o.org_contact_id
    FROM hz_matched_contacts_gt  gc,
         hz_relationships        r,
         hz_parties              p,
         hz_cust_account_roles   ro,
         hz_cust_acct_sites      asite,
         hz_org_contacts         o
   WHERE gc.search_context_id                   = i_ctx_id
     AND gc.score                               < 0
     AND -gc.party_id                           = i_cust_acct_id
     AND -gc.org_contact_id                     = ro.cust_account_role_id
     AND ro.cust_acct_site_id                   = i_acct_site_id
     AND ro.party_id                            = r.party_id
     AND r.directional_flag                     = 'B'
     AND r.object_id                            = p.party_id
     AND asite.cust_acct_site_id                = ro.cust_acct_site_id
     AND asite.party_site_id                    = o.party_site_id
     AND o.party_relationship_id                = r.relationship_id;
--     AND DECODE(i_status,'ALL','ALL',NVL(ro.status,'A')) = i_status;


  CURSOR c_contact_to_site2( i_ctx_id        NUMBER,
                             i_cust_acct_id  NUMBER,
                             i_acct_site_id  NUMBER,
                             i_status        VARCHAR2) IS
  SELECT distinct gc.score                     ,
         p.party_name                 ,
         p.party_number               ,
         p.party_id          person_id,
         ro.cust_account_role_id      ,
         r.party_id          rel_pty_id,
         r.relationship_code rel_code  ,
         o.org_contact_id
    FROM hz_matched_contacts_gt  gc,
         hz_relationships        r,
         hz_parties              p,
         hz_cust_account_roles   ro,
         hz_cust_acct_sites_all  asite,
         hz_org_contacts         o
   WHERE gc.search_context_id                   = i_ctx_id
     AND gc.score                               < 0
     AND -gc.party_id                           = i_cust_acct_id
     AND -gc.org_contact_id                     = ro.cust_account_role_id
     AND ro.cust_acct_site_id                   = i_acct_site_id
     AND ro.party_id                            = r.party_id
     AND r.directional_flag                     = 'B'
     AND r.object_id                            = p.party_id
     AND asite.cust_acct_site_id                = ro.cust_acct_site_id
     AND asite.party_site_id                    = o.party_site_id
     AND o.party_relationship_id                = r.relationship_id;
--     AND DECODE(i_status,'ALL','ALL',NVL(ro.status,'A')) = i_status;

  l_rec      c_contact_to_site%ROWTYPE;
  l_rec2     c_contact_to_site2%ROWTYPE;
  i          NUMBER;
  l_dsplist  dsplist;
  init_depth NUMBER;
  init_ndata VARCHAR2(2000);
  tp_dsplist dsplist;
  resultlist dsplist;
  l_score              VARCHAR2(30);
  -- for error usage
  tmp_var              VARCHAR2(2000);
  tmp_var1             VARCHAR2(2000);
BEGIN
  i            := 0;
  init_depth   := p_dsprec.depth;
  init_ndata   := p_dsprec.ndata;

  IF p_cur_all = 'CUR' THEN
    OPEN c_contact_to_site(p_ctx_id, p_cust_acct_id, p_acct_site_id, p_status);
    LOOP
      FETCH c_contact_to_site INTO l_rec;
      EXIT WHEN c_contact_to_site%NOTFOUND;
      i  :=  i + 1;
      l_dsplist(i).state := 0;
      l_dsplist(i).depth := init_depth + 1;
      l_dsplist(i).label := nvl(l_rec.party_name,'NULL');
      l_dsplist(i).icon  := ico_person;
      l_dsplist(i).ndata := atypstr(stypstr(init_ndata)||
                            'CUST_ACCOUNT_ROLE_ID:'||to_char(l_rec.cust_account_role_id)||
                            '@ORG_CONTACT_ID:'||to_char(l_rec.org_contact_id)||
                            '@PERSON_ID:'||to_char(l_rec.person_id)||
                            '@REL_PTY_ID:'||to_char(l_rec.rel_pty_id)||'@','CUST_ACCOUNT_ROLE');
      resultlist(resultlist.COUNT + 1) := l_dsplist(i);

      tp_dsplist := erase_list;
      tp_dsplist := Add_Ctp_to_Party(p_ctx_id,
                                   p_party_id,
                                   l_rec.rel_pty_id,
                                   p_status,
                                   l_dsplist(i));
      IF tp_dsplist.COUNT > 0 THEN
        resultlist(resultlist.COUNT).state := 1;
        resultlist := AddList( resultlist, tp_dsplist);
      END IF;

    END LOOP;
    CLOSE c_contact_to_site;
    RETURN resultlist;
  ELSIF p_cur_all = 'ALL' THEN
    OPEN c_contact_to_site2(p_ctx_id, p_cust_acct_id, p_acct_site_id, p_status);
    LOOP
      FETCH c_contact_to_site2 INTO l_rec2;
      EXIT WHEN c_contact_to_site2%NOTFOUND;
      i  :=  i + 1;
      l_dsplist(i).state := 0;
      l_dsplist(i).depth := init_depth + 1;
      l_dsplist(i).label := nvl(l_rec2.party_name,'NULL');
      l_dsplist(i).icon  := ico_person;
      l_dsplist(i).ndata := atypstr(stypstr(init_ndata)||'CUST_ACCOUNT_ROLE_ID:'||
                            to_char(l_rec2.cust_account_role_id)||
                            '@ORG_CONTACT_ID:'||to_char(l_rec2.org_contact_id)||
                            '@PERSON_ID:'||to_char(l_rec2.person_id)||'@REL_PTY_ID:'||to_char(l_rec2.rel_pty_id)||
                            '@','CUST_ACCOUNT_ROLE');
      resultlist(resultlist.COUNT + 1) := l_dsplist(i);

      tp_dsplist := erase_list;
      tp_dsplist := Add_Ctp_to_Party(p_ctx_id,
                                   p_party_id,
                                   l_rec2.rel_pty_id,
                                   p_status,
                                   l_dsplist(i));
      IF tp_dsplist.COUNT > 0 THEN
        resultlist(resultlist.COUNT).state := 1;
        resultlist := AddList( resultlist, tp_dsplist);
      END IF;

    END LOOP;
    CLOSE c_contact_to_site2;
    RETURN resultlist;
   END IF;
END;

END;

/
