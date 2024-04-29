--------------------------------------------------------
--  DDL for Package HR_CCMGR_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CCMGR_SS" AUTHID CURRENT_USER AS
/* $Header: hrccmwrs.pkh 115.6 2002/12/04 16:22:20 hjonnala noship $ */

-- ---------------------------------------------------------------------------
-- ---------------------------- < delete_trans_steps > -----------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure is used for deleting the transaction steps
--          pertaining to HR_CCMGR_SS module
-- ---------------------------------------------------------------------------

procedure delete_trans_steps(itemtype IN Varchar2
                            ,itemkey IN Varchar2
                            ,actid IN Number);

-- ---------------------------------------------------------------------------
-- ---------------------------- < validate_ccmgr_record > --------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure invokes the Organization Information api's
--          p_validate_mode (TRUE, FALSE): (Validation only, INS/UPD mode)
-- ---------------------------------------------------------------------------
procedure validate_ccmgr_record(p_ccmgr_rec IN HR_CCMGR_TYPE
                               ,p_validate_mode IN Boolean Default True
			       ,p_eff_date IN Date
                               ,p_warning OUT NOCOPY Boolean);

-- ---------------------------------------------------------------------------
-- ---------------------------- < process_api > ------------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure is used by the WF procedures to commit or validate
--          the transaction step with HRMS system
-- ---------------------------------------------------------------------------
procedure process_api(p_validate in boolean default false
                     ,p_transaction_step_id in number default null
                     ,p_effective_date in varchar2 default null);

-- ---------------------------------------------------------------------------
-- ---------------------------- < update_ccmgr_recs > ------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure process the transaction data entered and writes
--          into the transaction tables
-- ---------------------------------------------------------------------------
procedure update_ccmgr_recs(p_item_key IN Varchar2
                           ,p_item_type IN Varchar2
                           ,p_activity_id IN Number
                           ,p_login_person_id IN OUT NOCOPY Number
                           ,p_ccmgr_tbl IN OUT NOCOPY HR_CCMGR_TABLE
                           ,p_mode IN Varchar2 Default '#'
                           ,p_error_message OUT NOCOPY Long
                           ,p_status OUT NOCOPY Varchar2);

-- ---------------------------------------------------------------------------
-- ---------------------------- < get_supervisor_details > -------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure is used for defaulting supervisor if dealing
--          with terminated CCM
-- ---------------------------------------------------------------------------
procedure get_supervisor_details(p_emp_id IN Number,
                                 p_sup_id OUT NOCOPY Number,
                                 p_sup_name OUT NOCOPY Varchar2);

-- ---------------------------------------------------------------------------
-- ---------------------------- < issue_notify > -----------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure is used for decision crieteria wether to isuue a
--          a notification or not
-- ---------------------------------------------------------------------------
procedure issue_notify(itemtype IN Varchar2,
                                  itemkey IN Varchar2,
                                  actid IN Number,
                                  funmode IN Varchar2,
                                  result OUT NOCOPY Varchar2);

-- ---------------------------------------------------------------------------
-- ---------------------------- < get_noaccess_list > ------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure is used for constructing the plsql/clob document
--          used in the CCM notification
-- ---------------------------------------------------------------------------
procedure get_noaccess_list(document_id IN Varchar2,
                            display_type IN Varchar2,
                            document IN OUT NOCOPY Clob,
                            document_type IN OUT NOCOPY Varchar2);

end HR_CCMGR_SS;

 

/
