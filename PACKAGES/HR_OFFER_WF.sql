--------------------------------------------------------
--  DDL for Package HR_OFFER_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_OFFER_WF" AUTHID CURRENT_USER as
/* $Header: hrofwrwf.pkh 115.3 2002/12/12 07:01:06 hjonnala ship $ */
--
-- ------------------------------------------------------------------------
-- |----------------------< Start_Hroffer_Process>-------------------------|
-- ------------------------------------------------------------------------
	procedure Start_Hroffer_Process (p_hiring_mgr_id           in number
					,p_candidate_assignment_id in number
					,p_process	 	   in varchar2
                                        ,p_read_parameters         in varchar2);
--
--      03/07/97 Add a global value to store information whether the hiring
--               manager wants to bypass the next approver or not.
        g_bypass_next_apprvr   varchar2(1) := 'N';

-- ------------------------------------------------------------------------
-- |------------------------< Initialize >---------------------------------|
-- ------------------------------------------------------------------------
	procedure Initialize ( 	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funmode		in varchar2,
				result	 out nocopy varchar2	);
--
-- ------------------------------------------------------------------------
-- |------------------------< Get_next_approver >-------------------------|
-- ------------------------------------------------------------------------
	procedure Get_Next_Approver ( 	itemtype	in varchar2,
					itemkey  	in varchar2,
					actid		in number,
					funmode		in varchar2,
					result	 out nocopy varchar2	);
--
-- ------------------------------------------------------------------------
-- |----------------------< Check_Final_Approver >-------------------------|
-- ------------------------------------------------------------------------
	procedure Check_Final_Approver (itemtype	in varchar2,
					itemkey  	in varchar2,
					actid		in number,
					funmode		in varchar2,
					result	 out nocopy varchar2	);
--
-- ------------------------------------------------------------------------
-- |----------------------< Set_Status_To_Offer >-------------------------|
-- ------------------------------------------------------------------------
	procedure Set_Status_To_Offer ( itemtype	in varchar2,
					itemkey  	in varchar2,
					actid		in number,
					funmode		in varchar2,
					result	 out nocopy varchar2	);
--
-- ------------------------------------------------------------------------
-- |----------------------< Set_Status_To_Sent >---------------------------|
-- ------------------------------------------------------------------------
	procedure Set_Status_To_Sent ( itemtype	in varchar2,
					itemkey  	in varchar2,
					actid		in number,
					funmode		in varchar2,
					result	 out nocopy varchar2	);
--
-- ------------------------------------------------------------------------
-- |----------------------< Reset_Approval_Chain >-------------------------|
-- ------------------------------------------------------------------------
	procedure Reset_Approval_Chain(	itemtype	in varchar2,
					itemkey  	in varchar2,
					actid		in number,
					funmode		in varchar2,
					result	 out nocopy varchar2	);
--
-- ------------------------------------------------------------------------
-- |----------------------< Get_summary_URL >------------------------------|
-- ------------------------------------------------------------------------
	procedure Get_Summary_URL( 	itemtype	in varchar2,
					itemkey  	in varchar2,
					actid		in number,
					funmode		in varchar2,
					result	 out nocopy varchar2	);
--
-- ------------------------------------------------------------------------
-- |------------------------< Get_Offer_URL >------------------------------|
-- ------------------------------------------------------------------------
	procedure Get_Offer_URL( 	itemtype	in varchar2,
					itemkey  	in varchar2,
					actid		in number,
					funmode		in varchar2,
					result	 out nocopy varchar2	);
--
-- ------------------------------------------------------------------------
-- |------------------------< Get_Letter_URL >-----------------------------|
-- ------------------------------------------------------------------------
	procedure Get_Letter_URL( 	itemtype	in varchar2,
					itemkey  	in varchar2,
					actid		in number,
					funmode		in varchar2,
					result	 out nocopy varchar2	);
--
-- ------------------------------------------------------------------------
-- |------------------------< Get_HR_Routing_Details >---------------------|
-- ------------------------------------------------------------------------
	procedure Get_HR_Routing_Details(	itemtype	in varchar2,
						itemkey  	in varchar2,
						actid		in number,
						funmode		in varchar2,
						result	 out nocopy varchar2	);
--
-- ------------------------------------------------------------------------
-- |------------------------< copy_approval_comment >---------------------|
-- ------------------------------------------------------------------------
	procedure copy_approval_comment(itemtype	in varchar2,
					itemkey  	in varchar2,
					actid		in number,
					funmode		in varchar2,
					result	 out nocopy varchar2	);
--
--
-- ------------------------------------------------------------------------
-- |------------------------< Get_HR_Candidate_Details >---------------------|
-- ------------------------------------------------------------------------
   procedure Get_HR_Candidate_Details(itemtype        in varchar2,
                                      itemkey         in varchar2,
                                      actid           in number,
                                      funmode         in varchar2,
                                      result          out nocopy varchar2);

--
--
-- ------------------------------------------------------------------------
-- |------------------------< check_if_bypass >---------------------|
-- ------------------------------------------------------------------------
   procedure check_if_bypass(itemtype        in varchar2,
                             itemkey         in varchar2,
                             actid           in number,
                             funmode         in varchar2,
                             result          out nocopy varchar2);

--
--
-- ------------------------------------------------------------------------
-- |----------------------< Set_Bypass_To_No >---------------------------|
-- ------------------------------------------------------------------------
   procedure Set_Bypass_To_No (itemtype        in varchar2,
                               itemkey         in varchar2,
                               actid           in number,
                               funmode         in varchar2,
                               result          out nocopy varchar2);



end hr_offer_wf;

 

/
