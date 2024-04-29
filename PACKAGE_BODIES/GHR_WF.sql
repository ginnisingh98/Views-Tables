--------------------------------------------------------
--  DDL for Package Body GHR_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_WF" As
/* $Header: ghrwfnot.pkb 120.2 2005/06/28 15:05 sshetty noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'ghr_wf.';


PROCEDURE initiate_notification (p_request_id IN NUMBER
                                ,p_result_id  IN NUMBER
                                ,p_role       IN VARCHAR2
                                )
IS

CURSOR c_get_role_name
IS
SELECT * FROM WF_ROLES
WHERE NAME =p_role;

CURSOR c_get_rslt
IS
SELECT *
 FROM ben_ext_rslt
 WHERE ext_rslt_id= p_result_id
   AND request_id = p_request_id;


CURSOR c_dfn (cp_ext_dfn_id NUMBER)
IS
SELECT DISTINCT (bed.name)
  FROM ben_ext_dfn bed
 WHERE bed.ext_dfn_id=cp_ext_dfn_id;

CURSOR c_get_rec_cnt(cp_rslt_id   NUMBER
                    ,cp_dfn_id    NUMBER
                    )
IS
SELECT count(rslt.ext_rslt_id) rec_cnt
       FROM ben_ext_rcd_in_file rin
           ,ben_ext_dfn dfn
           ,ben_ext_rslt_dtl rslt
      WHERE dfn.ext_dfn_id   = cp_dfn_id
        AND rin.ext_file_id  = dfn.ext_file_id
        AND rin.hide_flag    = 'N'
        AND rin.ext_rcd_id   = rslt.EXT_RCD_ID
        and rslt.ext_rslt_id =cp_rslt_id;
l_get_rec_cnt c_get_rec_cnt%ROWTYPE;

l_dfn c_dfn%ROWTYPE;
l_get_role_name c_get_role_name%ROWTYPE;
l_get_rslt c_get_rslt%ROWTYPE;
l_get_seq VARCHAR2(30);
l_attr  varchar2(30);
l_ignore  boolean  ;
l_userkey varchar2(10);
l_owner varchar2(30);
BEGIN

 OPEN c_get_rslt;
 FETCH c_get_rslt INTO l_get_rslt;
 CLOSE c_get_rslt;


 OPEN c_get_rec_cnt (l_get_rslt.ext_rslt_id
                     ,l_get_rslt.ext_dfn_id);
 FETCH c_get_rec_cnt INTO l_get_rec_cnt;
 CLOSE c_get_rec_cnt;
 OPEN c_dfn (l_get_rslt.ext_dfn_id);
 FETCH c_dfn INTO l_dfn;
 CLOSE c_dfn;

 OPEN c_get_role_name;
 LOOP
  FETCH c_get_role_name INTO l_get_role_name;
  EXIT WHEN c_get_role_name%NOTFOUND;
 END LOOP;

 CLOSE c_get_role_name;
 SELECT ghr_nfc_notif_seq_s.nextval
   INTO l_get_seq
  FROM  dual;

 l_get_seq :='NFC'||l_get_seq;


 wf_engine.CreateProcess ('GHR',l_get_seq,'NOTIFYUSER');


 wf_engine.SetItemAttrText (
      itemType  => 'GHR',
      itemKey   => l_get_seq,
      aname     => 'USER_ROLE',
      avalue    => p_role);--l_get_role_name.name );

 l_attr:=  wf_engine.GetItemAttrText(
                         itemtype => 'GHR',
                         itemkey =>l_get_seq,
                         aname =>'NOTIF_TYPE',
                         ignore_notfound =>l_ignore);
   --
 IF l_attr='EVERY_TIME' THEN
  wf_engine.setItemAttrText (
      itemType  => 'GHR',
      itemKey   => l_get_seq,
      aname     => 'ERROR_WARN',
      avalue    => ben_ext_thread.g_err_cnt );
 IF ben_ext_thread.g_err_cnt > 0 THEN
   wf_engine.setItemAttrText (
      itemType  => 'GHR',
      itemKey   => l_get_seq,
      aname     => 'STATUS',
      avalue    => ' with Errors' );

 END IF;
  wf_engine.setItemAttrText (
      itemType  => 'GHR',
      itemKey   => l_get_seq,
      aname     => 'TOTALEXTRACT',
      avalue    => l_get_rec_cnt.rec_cnt );

   wf_engine.setItemAttrText (
      itemType  =>  'GHR',
      itemKey   => l_get_seq,
      aname     => 'REQUEST_ID',
      avalue    => p_request_id );

  IF INSTR(l_dfn.name,'Position') > 0 THEN
   wf_engine.setItemAttrText (
      itemType  =>  'GHR',
      itemKey   => l_get_seq,
      aname     => 'FILETYPE',
      avalue    => 'Position' );

  ELSIF INSTR(l_dfn.name,'Personnel') > 0 THEN
    wf_engine.setItemAttrText (
      itemType  =>  'GHR',
      itemKey   => l_get_seq,
      aname     => 'FILETYPE',
      avalue    => 'Personnel Action' );

  END IF;

  wf_engine.StartProcess ('GHR',l_get_seq);
 ELSIF  l_attr='ONLY_ERROR' THEN
  IF l_get_rslt.tot_err_num>0 THEN
   wf_engine.setItemAttrText (
      itemType  =>  'GHR',
      itemKey   => l_get_seq,
      aname     => 'ERROR_WARN',
      avalue    => ben_ext_thread.g_err_cnt );

   wf_engine.setItemAttrText (
      itemType  => 'GHR',
      itemKey   => l_get_seq,
      aname     => 'STATUS',
      avalue    => ' with Errors' );

   wf_engine.setItemAttrText (
      itemType  =>  'GHR',
      itemKey   => l_get_seq,
      aname     => 'TOTALEXTRACT',
      avalue    => l_get_rslt.TOT_REC_NUM );

    wf_engine.setItemAttrNumber (
      itemType  =>  'GHR',
      itemKey   => l_get_seq,
      aname     => 'REQUEST_ID',
      avalue    => p_request_id );

  IF INSTR(l_dfn.name,'Position') > 0 THEN
   wf_engine.setItemAttrText (
      itemType  =>  'GHR',
      itemKey   => l_get_seq,
      aname     => 'FILETYPE',
      avalue    => 'Position' );

  ELSIF INSTR(l_dfn.name,'Personnel') > 0 THEN
    wf_engine.setItemAttrText (
      itemType  =>  'GHR',
      itemKey   => l_get_seq,
      aname     => 'FILETYPE',
      avalue    => 'Personnel Action' );

  END IF;
   wf_engine.StartProcess ('GHR',l_get_seq);
  END IF;

 END IF;
END;

PROCEDURE CHECK_USER_EXIST
  (   itemtype                       in varchar2
    , itemkey                        in varchar2
    , actid                          in number
    , funcmode                       in varchar2
    , result                     out nocopy    varchar2
  )
IS
l_attr VARCHAR2(45);
l_ignore BOOLEAN;

CURSOR c_get_users(cp_role VARCHAR2)
IS
SELECT COUNT(*)
  FROM wf_user_roles wur
WHERE wur.role_name =cp_role;
l_count NUMBER;
BEGIN
 l_attr:=  wf_engine.GetItemAttrText(
                         itemtype => itemtype,
                         itemkey =>itemkey,
                         aname =>'USER_ROLE',
                         ignore_notfound =>l_ignore);
 OPEN c_get_users(l_attr) ;
 FETCH c_get_users INTO l_count;
 CLOSE c_get_users;
 IF l_count > 0 THEN
 result    := 'COMPLETE:'||'YES' ;
 ELSE

 result    := 'COMPLETE:'||'NO' ;
 END IF;



EXCEPTION
--------
WHEN OTHERS THEN
result    := 'COMPLETE:'||'NO' ;
NULL;
END;

end  GHR_WF;

/
