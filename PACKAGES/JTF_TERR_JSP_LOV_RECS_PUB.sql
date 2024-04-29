--------------------------------------------------------
--  DDL for Package JTF_TERR_JSP_LOV_RECS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TERR_JSP_LOV_RECS_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfpjlvs.pls 120.0 2005/06/02 18:20:42 appldev ship $ */
---------------------------------------------------------
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TERR_JSP_LOV_RECS_PUB
--    ---------------------------------------------------
--    PURPOSE
--      JTF/A Territories LOV Package
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      05/18/2001    EIHSU           Created
--    End of Comments
--

-- RESOURCE RECORDS
TYPE lov_inout_rec_type IS record
  (column1       varchar2(2000),
   column2       varchar2(2000),
   column3       varchar2(2000),
   column4       varchar2(2000),
   column5       varchar2(2000),
   column6       varchar2(2000),
   column7       varchar2(2000),
   column8       varchar2(2000),
   column9       varchar2(2000),
   column10      varchar2(2000),
   column11      varchar2(2000),
   column12      varchar2(2000),
   column13      varchar2(2000),
   column14      varchar2(2000),
   column15      varchar2(2000),
   -------------------------------
   filter1    varchar2(2000),
   filter2    varchar2(2000),
   filter3    varchar2(2000),
   filter4    varchar2(2000),
   filter5    varchar2(2000)
  );

TYPE lov_disp_format_rec_type IS record
  (column_number           number,
   column_display_enable   varchar2(1),
   column_search_enable    varchar2(1)
  );


TYPE lov_output_tbl_type IS table OF lov_inout_rec_type
  INDEX BY binary_integer;

TYPE lov_disp_format_tbl_type IS table OF lov_disp_format_rec_type
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

procedure Get_LOV_Records
(   p_range_low           IN NUMBER,
    p_range_high          IN NUMBER,
    p_record_group_name   IN VARCHAR2, -- name of the data to fetch
    p_in_filter_lov_rec   IN lov_inout_rec_type,
    x_total_rows          OUT NOCOPY NUMBER,
    x_more_data_flag      OUT NOCOPY VARCHAR2,
    x_lov_ak_region       OUT NOCOPY VARCHAR2,
    x_result_tbl          OUT NOCOPY lov_output_tbl_type,
    x_disp_format_tbl     OUT NOCOPY lov_disp_format_tbl_type
);


END JTF_TERR_JSP_LOV_RECS_PUB;

 

/
