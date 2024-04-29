--------------------------------------------------------
--  DDL for Package JTF_RS_GRP_SUM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_GRP_SUM_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfrssgs.pls 120.0 2006/02/09 15:00:02 baianand noship $ */
/*#
 * This package contains procedures to get group records
 * for JTT Group Advanced Search
 * @rep:scope private
 * @rep:product JTF
 * @rep:displayname Get Groups Package
 * @rep:category BUSINESS_ENTITY JTF_RS_GROUP
 */


---------------------------------------------------------
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_RS_GRP_SUM_PUB
--    ---------------------------------------------------
--    PURPOSE
--      Get group details for Group Summary Screen (jsp)
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      04/30/2001    NSINGHAI           Created
--    End of Comments
--

-- GROUP RECORDS
TYPE grp_sum_rec_type IS record
  (group_id           number,
   group_name         varchar2(60),
   group_desc         varchar2(240),
   group_number       varchar2(30),
   start_date_active  date,
   end_date_active    date,
   parent_group       varchar2(60),
   parent_group_id    number,
   child_group        varchar2(60),
   child_group_id     number
   );

TYPE grp_sum_tbl_type IS table OF grp_sum_rec_type
  INDEX BY binary_integer;

-- ***************************************************
--    start of comments
--    ***************************************************
--    api name       : Get Group Summary
--    type           : public.
--    function       : Get the Groups summary information
--    pre-reqs       : depends on jtf_rs_groups_vl
--    parameters     :
-- end of comments

/*#
 * This procedure gets group records based on the search criteria
 * mentioned in the other input parameters
 * @param p_range_low Lower range for record set
 * @param p_range_high Higher range for record set
 * @param p_called_from Indicator if its called from quick find or advanced search
 * @param p_user_id User id to filter groups by the membership of the user
 * @param p_group_name Group Name filter
 * @param p_group_number Group Number filter
 * @param p_group_desc Group Description filter
 * @param p_group_email Email filter
 * @param p_from_date To find groups active on or after the given date
 * @param p_to_date To find groups active on or before the given date
 * @param p_date_format date format for the dates specified
 * @param p_group_id Group's internal unique id to get a specific group
 * @param p_group_usage Groups based on group usage
 * @param x_total_rows Output parameter containing total number of rows returned
 * @param x_result_tbl Output parameter containing rows returned
 * @rep:scope private
 * @rep:displayname Get Groups
 */
PROCEDURE Get_Group
(   p_range_low           IN NUMBER,
    p_range_high          IN NUMBER,
    p_called_from         IN VARCHAR2 default 'DEFAULT',
    p_user_id             IN NUMBER default null,
    p_group_name          IN VARCHAR2 default null,
    p_group_number        IN VARCHAR2 default null,
    p_group_desc          IN VARCHAR2 default null,
    p_group_email         IN VARCHAR2 default null,
    p_from_date           IN VARCHAR2 default null,
    p_to_date             IN VARCHAR2 default null,
    p_date_format         IN VARCHAR2 default 'DD-MM-RRRR' ,
    p_group_id            IN NUMBER default null,
    p_group_usage         IN VARCHAR2 default null,
    x_total_rows          OUT NOCOPY NUMBER,
    x_result_tbl          OUT NOCOPY grp_sum_tbl_type);

END JTF_RS_GRP_SUM_PUB;


 

/
