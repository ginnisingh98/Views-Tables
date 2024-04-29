--------------------------------------------------------
--  DDL for Package PER_DTR_CHK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_DTR_CHK_PKG" AUTHID CURRENT_USER AS
/* $Header: pedtrchk.pkh 120.0 2006/06/26 15:31:52 debhatta noship $ */


procedure ghr_elt_ben_conv(p_result OUT nocopy varchar2);

procedure hraplupd1(p_result OUT nocopy varchar2);

procedure bencwbmu(p_result out nocopy varchar2);

END per_dtr_chk_pkg;

 

/
