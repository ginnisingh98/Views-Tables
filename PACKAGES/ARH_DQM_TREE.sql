--------------------------------------------------------
--  DDL for Package ARH_DQM_TREE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARH_DQM_TREE" AUTHID CURRENT_USER AS
/*$Header: ARHDQMTS.pls 115.0 2002/03/28 11:27:13 pkm ship   $*/

TYPE dsprec IS RECORD
( state    NUMBER,
  depth    NUMBER,
  label    VARCHAR2(2000),
  icon     VARCHAR2(30),
  ndata    VARCHAR2(2000));

TYPE dsplist IS TABLE OF dsprec INDEX BY BINARY_INTEGER;

erase_list  dsplist;


FUNCTION AddList
( p_dsplist1     dsplist,
  p_dsplist2     dsplist)
RETURN dsplist;

FUNCTION dsplist_for_parties
(p_ctx_id               IN NUMBER,
 p_status               IN VARCHAR2 DEFAULT 'ALL',
 p_disp_percent         IN VARCHAR2 DEFAULT 'Y')
RETURN dsplist;

FUNCTION Add_site_party
(p_ctx_id             IN     NUMBER,
 p_party_id           IN     NUMBER,
 p_status             IN     VARCHAR2 DEFAULT 'ALL',
 p_dsprec             IN     dsprec)
RETURN dsplist;

FUNCTION Add_Contact_party
(p_ctx_id             IN     NUMBER,
 p_party_id           IN     NUMBER,
 p_status             IN     VARCHAR2 DEFAULT 'ALL',
 p_dsprec             IN     dsprec)
RETURN dsplist;

FUNCTION Add_Ctp_to_Party_Site
(p_ctx_id           IN  NUMBER,
 p_party_id         IN  NUMBER,
 p_party_site_id    IN  NUMBER,
 p_status           IN  VARCHAR2 DEFAULT 'ALL',
 p_dsprec           IN  dsprec)
RETURN dsplist;

FUNCTION Add_Contact_to_site
( p_ctx_id        NUMBER,
  p_party_id      NUMBER,
  p_party_site_id NUMBER,
  p_status        IN VARCHAR2 DEFAULT 'ALL',
  p_dsprec        dsprec)
RETURN dsplist;

FUNCTION Add_Ctp_to_Party
(p_ctx_id           IN  NUMBER,
 p_party_id         IN  NUMBER,
 p_rel_pty_id       IN  NUMBER DEFAULT NULL,
 p_status           IN  VARCHAR2 DEFAULT 'ALL',
 p_dsprec           IN  dsprec)
RETURN dsplist;


----------040202

FUNCTION dsp_for_party_pty_accts
(p_ctx_id       IN NUMBER,
 p_cur_all      IN VARCHAR2 DEFAULT 'ALL',
 p_status       IN VARCHAR2 DEFAULT 'ALL',
 p_disp_percent IN VARCHAR2 DEFAULT 'Y')
RETURN dsplist;

FUNCTION dsp_for_party_accts
(p_ctx_id       IN NUMBER,
 p_cur_all      IN VARCHAR2 DEFAULT 'ALL',
 p_status       IN VARCHAR2 DEFAULT 'ALL',
 p_disp_percent IN VARCHAR2 DEFAULT 'Y')
RETURN dsplist;

FUNCTION add_acct_party
(p_ctx_id      IN NUMBER,
 p_party_id    IN NUMBER,
 p_cur_all     IN VARCHAR2 DEFAULT 'ALL',
 p_status      IN VARCHAR2 DEFAULT 'ALL',
 p_dsprec      IN dsprec)
RETURN dsplist;


FUNCTION Add_site_acct
(p_ctx_id             IN     NUMBER,
 p_party_id           IN     NUMBER,
 p_cust_acct_id       IN     NUMBER,
 p_cur_all            IN     VARCHAR2  DEFAULT 'ALL',
 p_status             IN     VARCHAR2  DEFAULT 'ALL',
 p_dsprec             IN     dsprec)
RETURN dsplist;


FUNCTION Add_Contact_Acct
(p_ctx_id             IN     NUMBER,
 p_party_id           IN     NUMBER,
 p_cust_acct_id       IN     NUMBER,
 p_status             IN     VARCHAR2 DEFAULT 'ALL',
 p_dsprec             IN     dsprec)
RETURN dsplist;

/*
FUNCTION Add_Contact_to_acct_site
( p_ctx_id        IN NUMBER,
  p_party_id      IN NUMBER,
  p_party_site_id IN NUMBER,
  p_cust_acct_id  IN NUMBER,
  p_acct_site_id  IN NUMBER,
  p_status        IN VARCHAR2 DEFAULT 'ALL',
  p_dsprec        IN dsprec)
RETURN dsplist;
*/

FUNCTION Add_Contact_to_acct_site
( p_ctx_id        IN NUMBER,
  p_party_id      IN NUMBER,
  p_cust_acct_id  IN NUMBER,
  p_acct_site_id  IN NUMBER,
  p_cur_all       IN VARCHAR2,
  p_status        IN VARCHAR2 DEFAULT 'ALL',
  p_dsprec        IN dsprec)
RETURN dsplist;

END;

 

/
