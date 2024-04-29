--------------------------------------------------------
--  DDL for Package PQH_SS_HISTORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_SS_HISTORY" AUTHID CURRENT_USER as
/* $Header: pqhstswi.pkh 120.0 2005/05/29 02:07:26 appldev noship $*/
 -- Global Variables
 G_ACTION  varchar2(25);


procedure transfer_to_history
    ( p_ItemType             in varchar2
    , p_itemKey              in varchar2
    , p_action               in varchar2
    , p_username             in varchar2
    , p_transactionId        in number
    , p_orig_system          in varchar2 default null
    , p_orig_system_id       in number default null);
--
procedure track_original_value
    ( p_ItemType             in varchar2
    , p_itemKey              in varchar2
    , p_action               in varchar2
    , p_username             in varchar2
    , p_transactionId        in number
    , p_orig_system          in varchar2 default null
    , p_orig_system_id       in number default null);
--
 PROCEDURE transfer_submit_to_history (
      itemtype        IN     VARCHAR2,
      itemkey         IN     VARCHAR2,
      actid           IN     NUMBER,
      funmode         IN     VARCHAR2,
      result          OUT NOCOPY VARCHAR2 );
--
--
 PROCEDURE transfer_approval_to_history (
      itemtype        IN     VARCHAR2,
      itemkey         IN     VARCHAR2,
      actid           IN     NUMBER,
      funmode         IN     VARCHAR2,
      result          OUT NOCOPY  VARCHAR2 );
--
--
 PROCEDURE transfer_reject_to_history (
      itemtype        IN     VARCHAR2,
      itemkey         IN     VARCHAR2,
      actid           IN     NUMBER,
      funmode         IN     VARCHAR2,
      result          OUT NOCOPY  VARCHAR2 );
--
--
 PROCEDURE transfer_delete_to_history (
      itemtype        IN     VARCHAR2,
      itemkey         IN     VARCHAR2,
      actid           IN     NUMBER,
      funmode         IN     VARCHAR2,
      result          OUT NOCOPY  VARCHAR2 );
--
--
 PROCEDURE transfer_startover_to_history (
      itemtype        IN     VARCHAR2,
      itemkey         IN     VARCHAR2,
      actid           IN     NUMBER,
      funmode         IN     VARCHAR2,
      result          OUT NOCOPY  VARCHAR2 );
--
--
 PROCEDURE transfer_rfc_to_history (
      itemtype        IN     VARCHAR2,
      itemkey         IN     VARCHAR2,
      actid           IN     NUMBER,
      funmode         IN     VARCHAR2,
      result          OUT NOCOPY  VARCHAR2 );
--
--
PROCEDURE copy_value_from_history (
        p_txnId        IN NUMBER );
--
--
PROCEDURE copy_value_to_history (
        p_txnId        IN NUMBER );
--
--
end;

 

/
