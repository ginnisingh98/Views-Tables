--------------------------------------------------------
--  DDL for Package HR_HRHD_RIR_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_HRHD_RIR_WF" AUTHID CURRENT_USER as
/* $Header: perhdrsyn.pkh 120.1.12010000.1 2008/10/20 15:05:38 sathkris noship $ */

/* Procedures called inside the workflow process HR RIR Process  starts */

/*procedure called for  create job api */
procedure create_job(itemtype   in varchar2,
           itemkey    in varchar2,
           actid      in number,
           funcmode   in varchar2,
            resultout  in out NOCOPY varchar2);

/*procedure called for  update job api */
procedure update_job(itemtype   in varchar2,
             itemkey    in varchar2,
             actid      in number,
             funcmode   in varchar2,
            resultout  in out NOCOPY varchar2);

 /*procedure called for delete job api*/
procedure delete_job(itemtype   in varchar2,
           itemkey    in varchar2,
           actid      in number,
           funcmode   in varchar2,
            resultout  in out NOCOPY varchar2);

 /*procedure called for create location api*/
procedure create_location(itemtype   in varchar2,
           itemkey    in varchar2,
           actid      in number,
           funcmode   in varchar2,
            resultout  in out NOCOPY varchar2);

 /*procedure called for update location api*/
procedure update_location(itemtype   in varchar2,
           itemkey    in varchar2,
           actid      in number,
           funcmode   in varchar2,
            resultout  in out NOCOPY varchar2);

 /*procedure called for delete location api*/
procedure delete_location(itemtype   in varchar2,
           itemkey    in varchar2,
           actid      in number,
           funcmode   in varchar2,
            resultout  in out NOCOPY varchar2);

/*procedure called for create Organization api*/
procedure create_organization(itemtype   in varchar2,
           itemkey    in varchar2,
           actid      in number,
           funcmode   in varchar2,
            resultout  in out NOCOPY varchar2);


/*procedure called for update Organization api*/
procedure update_organization(itemtype   in varchar2,
           itemkey    in varchar2,
           actid      in number,
           funcmode   in varchar2,
            resultout  in out NOCOPY varchar2);

/*procedure called for delete Organization api*/
procedure delete_organization(itemtype   in varchar2,
           itemkey    in varchar2,
           actid      in number,
           funcmode   in varchar2,
            resultout  in out NOCOPY varchar2);

/*procedure called for create person api*/
procedure create_person(itemtype   in varchar2,
           itemkey    in varchar2,
           actid      in number,
           funcmode   in varchar2,
            resultout  in out NOCOPY varchar2);

/*procedure called for update person api*/
procedure update_person(itemtype   in varchar2,
           itemkey    in varchar2,
           actid      in number,
           funcmode   in varchar2,
            resultout  in out NOCOPY varchar2);

/*procedure called for create or update address api*/
procedure cre_or_upd_address(itemtype   in varchar2,
           itemkey    in varchar2,
           actid      in number,
           funcmode   in varchar2,
            resultout  in out NOCOPY varchar2);

/*procedure called for create or update phone api*/
procedure cre_or_upd_phone(itemtype   in varchar2,
           itemkey    in varchar2,
           actid      in number,
           funcmode   in varchar2,
            resultout  in out NOCOPY varchar2);


/*procedure called for create  workforce api*/
procedure create_workforce(itemtype   in varchar2,
           itemkey    in varchar2,
           actid      in number,
           funcmode   in varchar2,
            resultout  in out NOCOPY varchar2);

/*procedure called for  update workforce api*/
procedure update_workforce(itemtype   in varchar2,
           itemkey    in varchar2,
           actid      in number,
           funcmode   in varchar2,
            resultout  in out NOCOPY varchar2);

/* Procedures called inside the workflow process HR RIR Process ends*/

/*Functions to generate the xml data starts*/

/*Function to generate the organization xml data*/
FUNCTION sif_organization_data(p_organization_id in number,
                               p_org_op_flag in varchar2,
                               p_date_to in boolean)
return clob;

/*Function to generate the person xml data*/
FUNCTION sif_person_data(p_person_id in number,
                         p_address_id in number,
                         p_phone_id in number,
                         p_person_op_flag in varchar2,
                         p_date in date)
return clob;

/*Function to generate the workforce data*/
FUNCTION   sif_workforce_data(p_assignment_id in number,
                              p_asg_op_flag in varchar2,
                              p_date in date)
return clob;

/*Function to generate the location data*/
FUNCTION  sif_location_data(p_location_id in number,
			    p_loc_op_flag in varchar2,
		            p_inactive_date in boolean)
return clob;

/*Function to generate the job data*/
FUNCTION sif_job_data(p_job_id in number,
                      p_job_op_flag in varchar2,
                      p_date_to in boolean)
return clob;

/*Functions to generate the xml data ends*/

/* Call backable Procedures definition starts */

procedure workforce_callbackable(my_parms in wf_parameter_list_t);

procedure person_callbackable(my_parms in wf_parameter_list_t);

procedure address_callbackable(my_parms in wf_parameter_list_t);

procedure phone_callbackable(my_parms in wf_parameter_list_t);

/* Call backable Procedures definition ends */

end HR_HRHD_RIR_WF;

/
