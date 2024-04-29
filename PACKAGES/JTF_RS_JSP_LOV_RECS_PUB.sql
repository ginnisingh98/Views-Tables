--------------------------------------------------------
--  DDL for Package JTF_RS_JSP_LOV_RECS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_JSP_LOV_RECS_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfrsjls.pls 120.0 2005/05/11 08:20:25 appldev ship $ */
/*#
 * This package contains procedures for getting records
 * to be displayed in an generic LOV for a given criteria
 * @rep:scope private
 * @rep:product JTF
 * @rep:displayname Generic LOV Package
 * @rep:category BUSINESS_ENTITY JTF_RS_RESOURCE_LOV
 */


---------------------------------------------------------
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_RS_JSP_LOV_RECS_PUB
--    ---------------------------------------------------
--    PURPOSE
--      Get resource details for JSP LOV Screens
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      05/18/2001    EIHSU           Created
--    End of Comments
--

-- RESOURCE RECORDS
TYPE lov_input_rec_type IS record
  (display_value    varchar2(2000),
   code_value       varchar2(100),
   aux_value1       varchar2(2000),
   aux_value2       varchar2(2000),
   aux_value3       varchar2(2000)
  );

TYPE lov_output_rec_type IS record
  (display_value    varchar2(2000),
   code_value       varchar2(100),
   aux_value1       varchar2(2000),
   aux_value2       varchar2(2000),
   aux_value3       varchar2(2000),
   ext_value1       varchar2(2000),
   ext_value2       varchar2(2000),
   ext_value3       varchar2(2000),
   ext_value4       varchar2(2000),
   ext_value5       varchar2(2000)
  );

TYPE lov_output_tbl_type IS table OF lov_output_rec_type
  INDEX BY binary_integer;

-- ***************************************************
--    start of comments
--    ***************************************************
--    api name       : Get_LOV_Records
--    type           : public.
--    function       :
--    pre-reqs       :
--    parameters     :
-- end of comments

/*#
 * Get LOV Records for a given criteria
 * @param p_range_low Lower range for record set
 * @param p_range_high Higher range for record set
 * @param p_record_group_name Indicated type of LOV
 * @param p_in_filter_lov_rec Record containing filter condition
 * @param p_in_filter1 Key to exclude a record
 * @param p_in_filter2 Key to exclude a record
 * @param x_total_rows Output parameter containing total rows returned
 * @param x_more_data_flag Output parameter containing indicator if there are more records possible
 * @param x_lov_ak_region Output parameter containing name of AK region containing LOV table column titles
 * @param x_result_tbl Output parameter containing PL/SQL Table containing the result set
 * @param x_ext_col_cnt Output parameter containing count of ext_value fields used in x_result_tbl
 * @rep:scope private
 * @rep:displayname Get LOV Records
 */
PROCEDURE Get_LOV_Records
(   p_range_low           IN NUMBER,
    p_range_high          IN NUMBER,
    p_record_group_name   IN VARCHAR2, -- name of the data to fetch
    p_in_filter_lov_rec   IN lov_input_rec_type,
    p_in_filter1          IN VARCHAR2, -- to restrict the data fetched
    p_in_filter2          IN VARCHAR2,
    x_total_rows          OUT NOCOPY NUMBER,
    x_more_data_flag      OUT NOCOPY VARCHAR2,
    x_lov_ak_region       OUT NOCOPY VARCHAR2,
    x_result_tbl          OUT NOCOPY lov_output_tbl_type,
    x_ext_col_cnt         OUT NOCOPY NUMBER);


END JTF_RS_JSP_LOV_RECS_PUB;

 

/
