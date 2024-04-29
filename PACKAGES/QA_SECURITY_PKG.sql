--------------------------------------------------------
--  DDL for Package QA_SECURITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_SECURITY_PKG" AUTHID CURRENT_USER AS
/* $Header: qltsecb.pls 120.1 2006/03/31 05:27:52 saugupta noship $ */


/* Package level variable */

TYPE ChildPlanArray IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

	pv_group_type CONSTANT varchar2(10) := 'QA';


  Procedure Create_Grant(EVENT in varchar2,
	     	p_grantee_id   in number, 	p_plan_id     in     number,
     		p_setup_flag   in varchar2, 	x_setup_guid  in out NOCOPY raw,
     	 	p_enter_flag   in varchar2, 	x_enter_guid  in out NOCOPY raw,
     		p_view_flag    in varchar2,  	x_view_guid   in out NOCOPY raw,
     		p_update_flag  in varchar2, 	x_update_guid in out NOCOPY raw,
     		p_delete_flag  in varchar2, 	x_delete_guid in out NOCOPY raw);

  Procedure security_predicate( p1_function      in  varchar2,
                		p1_object_name   in  varchar2,
                		p1_user_name     in  varchar2,
                		x1_predicate     out NOCOPY varchar2,
                		x1_return_status out NOCOPY varchar2);

  -- Bug2379185. Changed the signature of the function.
  -- Included p_check_immediate parameter and x_child_plan_ids changed to 'in out' parameter
  -- rponnusa Thu May 16 19:25:20 PDT 2002
  Function child_security( p_function_name  IN VARCHAR2,
                           p_user           IN VARCHAR2,
                           x_child_plan_ids IN OUT NOCOPY VARCHAR2,
                           p_parent_plan_id IN NUMBER,
			   p_check_immediate IN BOOLEAN)
  RETURN VARCHAR2;

  Procedure Create_Group( p_group_name     in  varchar2,
			  x1_msg_data 	   out NOCOPY varchar2,
			  x1_return_status out NOCOPY varchar2,
                          x1_party_id 	   out NOCOPY number);

  Procedure Create_Person(p_fname    	   in  varchar2,
			  p_lname    	   in  varchar2,
			  x1_msg_data 	   out NOCOPY varchar2,
			  x1_return_status out NOCOPY varchar2,
                          x1_party_id 	   out NOCOPY number);

  Procedure Create_Relationship(p_subject_id       in number,
				p_object_id        in number,
			  	x1_msg_data 	   out NOCOPY varchar2,
			  	x1_return_status   out NOCOPY varchar2,
                          	x1_party_id 	   out NOCOPY number,
				x1_relationship_id out NOCOPY number);


  Procedure Update_Group(p_group_name      in varchar2,
			 p_party_id        in number,
                         p_date            in date,
			 x1_msg_data 	   out NOCOPY varchar2,
			 x1_return_status  out NOCOPY varchar2);

  Procedure Update_Person(p_fname    	    in varchar2,
			  p_lname    	    in varchar2,
                          p_party_id 	    in number,
			  p_date     	    in date,
			  x1_msg_data 	    out NOCOPY varchar2,
			  x1_return_status  out NOCOPY varchar2);

  Procedure Delete_Relationship(p_relationship_id in number);

  Procedure Update_Relationship(p_relationship_id       in number,
                                p_subject_id            in number,
                                p_object_id             in number,
                                p_party_id              in number,
                                p_status                in varchar2,
				p_rel_date		in date,
				p_party_date		in date,
                                x1_return_status        out NOCOPY varchar2,
                                x1_msg_data             out NOCOPY varchar2);


  -- anagarwa Tue Aug  3 12:26:09 PDT 2004
  -- bug 3695361: Slow performance when security is on
  -- Following procedure takes in used id instead of user name and
  -- finds user name and then calls original security_predicate
  PROCEDURE ssqr_security_predicate(p2_function      in  varchar2,
                             p2_object_name   in  varchar2,
                             p2_user_id     in  number,
                             x2_predicate     out NOCOPY varchar2,
                             x2_return_status out NOCOPY varchar2) ;
END QA_SECURITY_PKG;

 

/
