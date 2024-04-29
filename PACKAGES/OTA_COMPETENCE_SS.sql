--------------------------------------------------------
--  DDL for Package OTA_COMPETENCE_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_COMPETENCE_SS" AUTHID CURRENT_USER as
/* $Header: otcmpupd.pkh 120.1 2005/06/13 02:56:22 dbatra noship $ */


-- Global variables
   g_date_format varchar2(10) := 'RRRR/MM/DD';

--  ---------------------------------------------------------------------------
--  |----------------------< check_Update_competence >--------------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE check_Update_competence  ( itemtype		IN WF_ITEMS.ITEM_TYPE%TYPE,
		      itemkey		IN WF_ITEMS.ITEM_KEY%TYPE,
		      actid		IN NUMBER,
	   	      funcmode		IN VARCHAR2,
		      resultout		OUT nocopy VARCHAR2 );

--  ---------------------------------------------------------------------------
--  |----------------------< Update_competence >--------------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE Update_competence  ( itemtype		IN WF_ITEMS.ITEM_TYPE%TYPE,
		      itemkey		IN WF_ITEMS.ITEM_KEY%TYPE,
		      actid		IN NUMBER,
	   	      funcmode		IN VARCHAR2,
		      resultout		OUT nocopy VARCHAR2 );

--  ---------------------------------------------------------------------------
--  |----------------------< get_approval_req >--------------------------|
--  ---------------------------------------------------------------------------
--

PROCEDURE get_approval_req  ( itemtype		IN WF_ITEMS.ITEM_TYPE%TYPE,
		      itemkey		IN WF_ITEMS.ITEM_KEY%TYPE,
		      actid		IN NUMBER,
	   	      funcmode		IN VARCHAR2,
		      resultout		OUT nocopy VARCHAR2 );
--  ---------------------------------------------------------------------------
--  |----------------------< validate_competence_update >--------------------------|
--  ---------------------------------------------------------------------------
--

procedure validate_competence_update
 (p_item_type     in varchar2,
  p_item_key      in varchar2,
  p_message out nocopy varchar2);


Function generate_url(p_func varchar2) return varchar2;
/*
  ||===========================================================================
  || PROCEDURE: create_wf_process
  ||---------------------------------------------------------------------------
  ||
  || Description:
  || Description:
  ||     This procedure will launch the workflow process required to update
  || competencies
  ||
  ||
  || Pre Conditions:
  ||
  || In Arguments:
  ||
  ||
  ||
  || out  Arguments:
  ||
  || In out Arguments:
  ||
  || Post Success:
  ||
  ||
  || Post Failure:
  ||     Raises an exception
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */

     Procedure create_wf_process(p_process 	in wf_process_activities.process_name%type,
            p_itemtype 		in wf_items.item_type%type,
            p_person_id 	in number ,
            p_eventid       in ota_Events.event_id%type default null,
            p_learningpath_ids in varchar2 default null,
            p_certification_Id in number default null,
            p_itemkey       out nocopy wf_items.item_key%type);
 /*
  ||===========================================================================
  || PROCEDURE: save_Comptence_info
  ||---------------------------------------------------------------------------
  ||
  || Description:
  || Description:
  ||     This procedure will save the comptency relaetd information in transaction
  || table
  ||
  || Pre Conditions:
  ||
  || In Arguments:
  ||
  ||
  ||
  || out  Arguments:
  ||
  || In out Arguments:
  ||
  || Post Success:
  ||
  ||
  || Post Failure:
  ||     Raises an exception
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */

   Procedure save_Comptence_info(
            p_person_id 	in number ,
            p_item_type 		in wf_items.item_type%type,
            p_item_key       in wf_items.item_key%type,
            p_Competence_id  in varchar2,
            p_level_id      in varchar2,
            p_level_override in varchar2 default null,
            p_date_from     in varchar2 default null,
            p_date_to       in varchar2 default null,
            p_source        in varchar2 default null,
            p_certification_date in varchar2 default null,
            p_certification_method in varchar2 default null,
            p_certification_next in varchar2 default null,
            p_comments in varchar2 default null,
            p_from in varchar2 default null);

/*
  ||===========================================================================
  || PROCEDURE: get_Comptence_eff_date
  ||---------------------------------------------------------------------------
  ||
  || Description:
  || Description:
  ||     This procedure will get the competency relaetd date to be
  || saved in transaction table
  ||
  ||
  || Pre Conditions:
  ||
  || In Arguments:
  ||
  ||
  ||
  || out  Arguments:
  ||
  || In out Arguments:
  ||
  || Post Success:
  ||
  ||
  || Post Failure:
  ||     Raises an exception
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */

    Function get_Competence_eff_date(
            p_comp_id in per_competence_elements.competence_id%type,
            p_id 		in ota_events.event_id%type,
            p_obj_type in varchar2
           ) return date;

    /*
  ||===========================================================================
  || PROCEDURE: get_review_data
  ||---------------------------------------------------------------------------
  ||
  || Description:
  || Description:
  ||     This procedure will get the competency relaetd information from transaction table
  ||
  ||
  || Pre Conditions:
  ||
  || In Arguments:
  ||
  ||
  ||
  || out  Arguments:
  ||
  || In out Arguments:
  ||
  || Post Success:
  ||
  ||
  || Post Failure:
  ||     Raises an exception
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */


    PROCEDURE get_review_data
   (p_item_type                       in  varchar2
   ,p_item_key                        in  varchar2
   ,p_review_data                     out nocopy long
   ,p_from                            out nocopy varchar2);

   PROCEDURE process_api
        (p_validate IN BOOLEAN default false,p_transaction_step_id IN NUMBER default null);

      /*
  ||===========================================================================
  || PROCEDURE: COMP_RETREIVE
  ||---------------------------------------------------------------------------
  ||
  || Description:
  || Description:
  ||     This procedure will get the competency relaetd information from base table
  ||  for an event and associated LP (if completed)
  ||
  ||
  || Pre Conditions:
  ||
  || In Arguments:
  ||
  ||
  ||
  || out  Arguments:
  ||
  || In out Arguments:
  ||
  || Post Success:
  ||
  ||
  || Post Failure:
  ||     Raises an exception
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */

    PROCEDURE COMP_RETREIVE ( p_event_id IN NUMBER
			, p_learning_path_ids IN VARCHAR2
            , p_certification_id IN Number
            , p_person_id in number default null
			, p_comp_ids OUT NOCOPY VARCHAR2
			, p_level_ids OUT NOCOPY VARCHAR2
            ,p_eff_date_from out nocopy varchar2
            ,p_eff_date_to out nocopy varchar2);

end ota_Competence_ss;



 

/
