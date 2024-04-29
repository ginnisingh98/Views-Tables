--------------------------------------------------------
--  DDL for Package GMD_QC_SPEC_MATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_QC_SPEC_MATCH" AUTHID CURRENT_USER AS
/* $Header: GMDQMCHS.pls 120.0 2005/05/26 01:05:11 appldev noship $ */

-- ==================================================
-- Do not use %TYPE so the Pick Lots screen can be sent
-- out without QC data model changes.
-- Location in match_result_lot_rec is being ignored for now.
--   So you can leave it blank.
-- Spec Matching should send N for exact match and Y for look_in_other_orgn
-- Spec Matching should ignore the qcassy_typ_id.  It is used by the Form
--  if the user adds assays not on the spec to results.
-- Spec Matching should ignore lot_id which is used when procedure is called
--  from the results form.  Lot would be used if no customer spec was found
--  and an item/loc spec had to be searched.
-- Spec Matching should ignore order_line, which is the concatenated line
--  number shown on an order.  This concatenated line is stored on a sample.
--  The simple numeric line_number is stored on a spec.
-- ==================================================

TYPE find_cust_spec_rec IS record
                     ( orgn_code                   VARCHAR2(4)
                      ,whse_code                   VARCHAR2(4)
                      ,customer_id                 NUMBER
                      ,item_id                     NUMBER
                      ,date_effective              date
                      ,order_org_id                NUMBER
                      ,ship_to_site_id             NUMBER
                      ,order_header_id             NUMBER
                      ,order_line_id               NUMBER
                      ,exact_match                 VARCHAR2(1)
                      ,look_in_other_orgn          VARCHAR2(1)
                      ,order_line                  VARCHAR2(16)
                      ,lot_id                      NUMBER
                      ,qcassy_typ_id               NUMBER
                     ) ;

TYPE cust_spec_out_rec IS record
                     ( spec_hdr_id                 NUMBER
                      ,orgn_code                   VARCHAR2(4)
                      ,qc_spec_id                  NUMBER
                     ) ;

TYPE cust_spec_out_tbl IS TABLE OF cust_spec_out_rec INDEX BY BINARY_INTEGER;  --Bug 2798879

TYPE match_result_lot_rec IS record
                    ( item_id          NUMBER                       -- IN
                     ,lot_id           NUMBER                       -- IN
                     ,whse_code        VARCHAR2(4)                  -- IN
                     ,location         VARCHAR2(16)                 -- IN
                     ,sample_id        NUMBER                       -- OUT
                     ,qc_rec_type      VARCHAR2(4)                  -- OUT
                     ,spec_match_type  VARCHAR2(4)                  -- OUT
                     );

-- ==================================================
-- Currently, Apps says we should have separate IN and OUT parameters.
-- So we are declaring two tables, one IN and one OUT, with the same
-- record type.  If the function finds a customer spec, then the procedure
-- needs to find a set of results (given by sample_id) for that spec for
-- each lot given.
-- ==================================================

TYPE result_lot_match_tbl  IS TABLE OF match_result_lot_rec
       INDEX BY BINARY_INTEGER;


-- send in orgn_code, cust_id, item_id, order_id (if any), sched ship date
-- for Date_effective.
-- return spec_hdr_id, orgn_code of spec found

FUNCTION find_cust_spec ( p_cust_spec     IN  find_cust_spec_rec)
                          RETURN cust_spec_out_tbl ;    --BUG#2798879

PROCEDURE get_spec_match
                  (  p_spec_hdr_id   IN  NUMBER
                   , p_lots_in       IN  result_lot_match_tbl
                   , p_api_version   IN NUMBER
                   , p_init_msg_list IN VARCHAR2  := FND_API.G_FALSE
                   , p_results_out   OUT NOCOPY result_lot_match_tbl  --BUG#4203815
                   , p_return_status OUT NOCOPY VARCHAR2
                   , p_msg_count     OUT NOCOPY NUMBER
                   , p_msg_stack     OUT NOCOPY VARCHAR2
                  );


END   gmd_qc_spec_match;

 

/
