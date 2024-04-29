--------------------------------------------------------
--  DDL for Package FTE_QP_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_QP_ENGINE" AUTHID CURRENT_USER as
/* $Header: FTEFRQPS.pls 115.10 2003/11/14 01:51:43 vphalak ship $ */

-- This package encapsulates all qp engine related methods and data structures.
-- It provides several utility packages to create engine input records.
-- It will also hold engine i/p and o/p in global tables per event.

  /*
   TYPE pricing_control_input_rec_type IS RECORD (
        pricing_event_num         NUMBER,
        currency_code             VARCHAR2(30),
        lane_id                   NUMBER,
        price_list_id             NUMBER,
        party_id                  NUMBER
   );
  */

   TYPE pricing_engine_def_rec_type    IS RECORD (
        pricing_event_num         NUMBER,   --index
        pricing_event_code        VARCHAR2(30),
        request_type_code         VARCHAR2(30),
        line_type_code            VARCHAR2(30),
        price_flag                VARCHAR2(1)
   );

   TYPE pricing_engine_def_tab_type IS TABLE OF pricing_engine_def_rec_type INDEX BY BINARY_INTEGER;

   -- brought over from freight pricing. Contains some changes
   /*
   TYPE pricing_engine_input_rec_type IS RECORD
                (input_index                                    NUMBER , -- Same as QP engine line_index ?
                 instance_index                                 NUMBER ,  -- Origin pricing dual instance. Can be more than one input rec only in case of pricing objective consideration/percel hundredwt.
                 category_id                                    NUMBER DEFAULT NULL, -- Populated for WITHIN
                 basis                                          NUMBER DEFAULT NULL, -- Populated for ACROSS
                 line_quantity                                  NUMBER ,
                 line_uom                                       VARCHAR2(60)  ,
                 input_set_number                               NUMBER DEFAULT 1  -- indentifies an input set (for stuff like parcel hundred wt)
                 );

   TYPE pricing_engine_input_tab_type IS TABLE OF pricing_engine_input_rec_type INDEX BY BINARY_INTEGER;
  */


  /*
   -- brought over from freight pricing. Contains some changes
   TYPE pricing_attribute_rec_type IS RECORD
                (attribute_index                                NUMBER ,
                 input_index                                    NUMBER , -- Origin QP engine input line index
                 attribute_name                                 VARCHAR2(60) ,
                 attribute_value                                VARCHAR2(240),
                 attribute_value_to                             VARCHAR2(240) DEFAULT NULL
                 );

   TYPE pricing_attribute_tab_type IS TABLE OF pricing_attribute_rec_type INDEX BY BINARY_INTEGER;
  */

   TYPE qualifier_rec_type IS RECORD
                (qualifier_index                                NUMBER ,
                 input_index                                    NUMBER , -- Origin QP engine input line index
                 qualifier_name                                 VARCHAR2(60) ,
                 qualifier_value                                VARCHAR2(240),
                 qualifier_value_to                             VARCHAR2(240) DEFAULT NULL,
                 operator                                       VARCHAR2(30)  DEFAULT '='
                 );

   -- This type stores additional stuff that should go along with a qp line_rec
   -- mainly used to associate set number to a line rec
   TYPE line_extras_rec IS RECORD
                (  line_index                                           NUMBER,
                   input_set_number                                     NUMBER,
                   category_id                                          NUMBER
                 );
   -- This table will have one record per input line rec
   TYPE line_extras_tab_type IS TABLE OF line_extras_rec INDEX BY BINARY_INTEGER;


   TYPE commodity_price_rec_type  IS RECORD (
           category_id               NUMBER, --index
           unit_price                NUMBER,
           total_wt                  NUMBER,
           priced_uom                VARCHAR2(30),       -- AG 5/12
           output_line_index         NUMBER,       -- AG 5/13
           output_line_priced_quantity NUMBER,       -- xizhang 11/22/02 in original line uom
           wt_uom                    VARCHAR2(30) );  -- This will always be in deficit wt. uom

   TYPE commodity_price_tbl_type IS TABLE OF commodity_price_rec_type INDEX BY BINARY_INTEGER;


-- Parcel output conditions
   G_PAR_NO_MP_PRICE   NUMBER := 1; -- singlepiece all line successful, multipiece all line ipl
   G_PAR_NO_SP_PRICE   NUMBER := 2; -- singlepiece all line ipl or parcial ipl, multipiece all line successful



-- pricing events
G_LINE_EVENT_NUM    NUMBER := 1;
G_CHARGE_EVENT_NUM  NUMBER := 2;
--G_LINE_EVENT_CODE    VARCHAR2(30) := 'LINE';
--G_CHARGE_EVENT_CODE  VARCHAR2(30) := 'PRICE_LOAD';  -- should have a proper value (say FTE_CHARGE_EVENT)
G_LINE_EVENT_CODE    VARCHAR2(30) := 'FTE_PRICE_LINE';
G_CHARGE_EVENT_CODE  VARCHAR2(30) := 'FTE_APPLY_MOD';  -- should have a proper value (say FTE_CHARGE_EVENT)

G_EXTRAS_OFFSET    NUMBER := 100000; -- offset that is used to lookup into the extras tbl


  -- input to QP
  G_I_LINE_INDEX                   QP_PREQ_GRP.PLS_INTEGER_TYPE;
  G_I_LINE_TYPE_CODE               QP_PREQ_GRP.VARCHAR_TYPE;
  G_I_PRICING_EFFECTIVE_DATE       QP_PREQ_GRP.DATE_TYPE   ;
  G_I_ACTIVE_DATE_FIRST            QP_PREQ_GRP.DATE_TYPE   ;
  G_I_ACTIVE_DATE_FIRST_TYPE       QP_PREQ_GRP.VARCHAR_TYPE;
  G_I_ACTIVE_DATE_SECOND           QP_PREQ_GRP.DATE_TYPE   ;
  G_I_ACTIVE_DATE_SECOND_TYPE      QP_PREQ_GRP.VARCHAR_TYPE ;
  G_I_LINE_QUANTITY                QP_PREQ_GRP.NUMBER_TYPE ;
  G_I_LINE_UOM_CODE                QP_PREQ_GRP.VARCHAR_TYPE;
  G_I_REQUEST_TYPE_CODE            QP_PREQ_GRP.VARCHAR_TYPE;
  G_I_PRICED_QUANTITY              QP_PREQ_GRP.NUMBER_TYPE;
  G_I_PRICED_UOM_CODE              QP_PREQ_GRP.VARCHAR_TYPE;
  G_I_CURRENCY_CODE                QP_PREQ_GRP.VARCHAR_TYPE;
  G_I_UNIT_PRICE                   QP_PREQ_GRP.NUMBER_TYPE;
  G_I_PERCENT_PRICE                QP_PREQ_GRP.NUMBER_TYPE;
  G_I_UOM_QUANTITY                 QP_PREQ_GRP.NUMBER_TYPE;
  G_I_ADJUSTED_UNIT_PRICE          QP_PREQ_GRP.NUMBER_TYPE;
  G_I_UPD_ADJUSTED_UNIT_PRICE      QP_PREQ_GRP.NUMBER_TYPE;
  G_I_PROCESSED_FLAG               QP_PREQ_GRP.VARCHAR_TYPE;
  G_I_PRICE_FLAG                   QP_PREQ_GRP.VARCHAR_TYPE;
  G_I_LINE_ID                      QP_PREQ_GRP.NUMBER_TYPE;
  G_I_PROCESSING_ORDER             QP_PREQ_GRP.PLS_INTEGER_TYPE;
  G_I_PRICING_STATUS_CODE          QP_PREQ_GRP.VARCHAR_TYPE;
  G_I_PRICING_STATUS_TEXT          QP_PREQ_GRP.VARCHAR_TYPE;
  G_I_ROUNDING_FLAG                QP_PREQ_GRP.FLAG_TYPE;
  G_I_ROUNDING_FACTOR              QP_PREQ_GRP.PLS_INTEGER_TYPE;
  G_I_QUALIFIERS_EXIST_FLAG        QP_PREQ_GRP.VARCHAR_TYPE;
  G_I_PRICING_ATTRS_EXIST_FLAG     QP_PREQ_GRP.VARCHAR_TYPE;
  G_I_PRICE_LIST_ID                QP_PREQ_GRP.NUMBER_TYPE;
  G_I_VALIDATED_FLAG               QP_PREQ_GRP.VARCHAR_TYPE;
  G_I_PRICE_REQUEST_CODE           QP_PREQ_GRP.VARCHAR_TYPE;
  G_I_USAGE_PRICING_TYPE           QP_PREQ_GRP.VARCHAR_TYPE;
  G_I_LINE_CATEGORY                QP_PREQ_GRP.VARCHAR_TYPE;

  G_I_A_LINE_INDEX                 QP_PREQ_GRP.PLS_INTEGER_TYPE;
  G_I_A_LINE_DETAIL_INDEX          QP_PREQ_GRP.PLS_INTEGER_TYPE;
  G_I_A_ATTRIBUTE_LEVEL            QP_PREQ_GRP.VARCHAR_TYPE;
  G_I_A_ATTRIBUTE_TYPE             QP_PREQ_GRP.VARCHAR_TYPE;
  G_I_A_LIST_HEADER_ID             QP_PREQ_GRP.NUMBER_TYPE;
  G_I_A_LIST_LINE_ID               QP_PREQ_GRP.NUMBER_TYPE;
  G_I_A_CONTEXT                    QP_PREQ_GRP.VARCHAR_TYPE;
  G_I_A_ATTRIBUTE                  QP_PREQ_GRP.VARCHAR_TYPE;
  G_I_A_VALUE_FROM                 QP_PREQ_GRP.VARCHAR_TYPE;
  G_I_A_SETUP_VALUE_FROM           QP_PREQ_GRP.VARCHAR_TYPE;
  G_I_A_VALUE_TO                   QP_PREQ_GRP.VARCHAR_TYPE;
  G_I_A_SETUP_VALUE_TO             QP_PREQ_GRP.VARCHAR_TYPE;
  G_I_A_GROUPING_NUMBER            QP_PREQ_GRP.PLS_INTEGER_TYPE;
  G_I_A_NO_QUALIFIERS_IN_GRP       QP_PREQ_GRP.PLS_INTEGER_TYPE;
  G_I_A_COMPARISON_OPERATOR_TYPE   QP_PREQ_GRP.VARCHAR_TYPE;
  G_I_A_VALIDATED_FLAG             QP_PREQ_GRP.VARCHAR_TYPE;
  G_I_A_APPLIED_FLAG               QP_PREQ_GRP.VARCHAR_TYPE;
  G_I_A_PRICING_STATUS_CODE        QP_PREQ_GRP.VARCHAR_TYPE;
  G_I_A_PRICING_STATUS_TEXT        QP_PREQ_GRP.VARCHAR_TYPE;
  G_I_A_QUALIFIER_PRECEDENCE       QP_PREQ_GRP.PLS_INTEGER_TYPE;
  G_I_A_DATATYPE                   QP_PREQ_GRP.VARCHAR_TYPE;
  G_I_A_PRICING_ATTR_FLAG          QP_PREQ_GRP.VARCHAR_TYPE;
  G_I_A_QUALIFIER_TYPE             QP_PREQ_GRP.VARCHAR_TYPE;
  G_I_A_PRODUCT_UOM_CODE           QP_PREQ_GRP.VARCHAR_TYPE;
  G_I_A_EXCLUDER_FLAG              QP_PREQ_GRP.VARCHAR_TYPE;
  G_I_A_PRICING_PHASE_ID           QP_PREQ_GRP.PLS_INTEGER_TYPE;
  G_I_A_INCOMPATABILITY_GRP_CODE   QP_PREQ_GRP.VARCHAR_TYPE;
  G_I_A_LINE_DETAIL_TYPE_CODE      QP_PREQ_GRP.VARCHAR_TYPE;
  G_I_A_MODIFIER_LEVEL_CODE        QP_PREQ_GRP.VARCHAR_TYPE;
  G_I_A_PRIMARY_UOM_FLAG           QP_PREQ_GRP.VARCHAR_TYPE;

  g_I_control_rec                  QP_PREQ_GRP.CONTROL_RECORD_TYPE;
  g_I_line_extras_tbl              line_extras_tab_type;

  -- output from QP
  g_O_line_tbl                     QP_PREQ_GRP.LINE_TBL_TYPE;
  g_O_line_detail_tbl              QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE;

 -- stores defaults for each pricing event
 --g_engine_defaults_tab       pricing_engine_def_tab_type;



 -- we need procedures to :
 --        create the control record
 --        create line record
 --        create attribute record
 --        create qualifier record

 -- creates a control record based on defaults and adds it to the input table for the event
 PROCEDURE create_control_record (p_event_num  IN NUMBER,
                                  x_return_status  OUT NOCOPY  VARCHAR2);

 -- creates a single line record and adds it to the event input table
 PROCEDURE  create_line_record (p_pricing_control_rec       IN  fte_freight_pricing.pricing_control_input_rec_type,
                                p_pricing_engine_input_rec  IN  fte_freight_pricing.pricing_engine_input_rec_type,
                                x_return_status             OUT NOCOPY  VARCHAR2);

 -- creates a single qualifier record and adds it to the appropriate i/p table
 PROCEDURE  create_qual_record (p_event_num             IN  NUMBER,
                                p_qual_rec              IN  qualifier_rec_type,
                                x_return_status         OUT NOCOPY  VARCHAR2);

 -- creates a single attribute record and adds it to the appropriate i/p table
 PROCEDURE  create_attr_record         (p_event_num             IN  NUMBER,
                                        p_attr_rec              IN  fte_freight_pricing.pricing_attribute_rec_type,
                                        x_return_status         OUT NOCOPY  VARCHAR2);

-- This procedure is called to create pricing attributes per line rec from the input attr rows
PROCEDURE prepare_qp_line_attributes (
        p_event_num               IN     NUMBER,
        p_input_index             IN     NUMBER,
        p_attr_rows               IN     fte_freight_pricing.pricing_attribute_tab_type,
        x_return_status           OUT NOCOPY     VARCHAR2 );

PROCEDURE prepare_qp_line_qualifiers (p_event_num            IN     NUMBER,
                                      p_pricing_control_rec     IN     fte_freight_pricing.pricing_control_input_rec_type,
                                      p_input_index             IN     NUMBER,
                                      x_return_status           OUT NOCOPY     VARCHAR2 );


-- add one qp output line detail record into qp output line detail table
-- most of the qp output should come directly from qp
-- since qp cannot handle all of FTE pricing reqirement (e.g. deficit weight for LTL)
-- In some cases, FTE pricing engine needs to add some more records into
-- qp output tables
PROCEDURE add_qp_output_detail(
  p_line_index		IN NUMBER,
  p_list_line_type_code	IN VARCHAR2,
  p_charge_subtype_code IN VARCHAR2,
  p_adjustment_amount	IN NUMBER,
  x_return_status OUT NOCOPY  VARCHAR2);

--PROCEDURE call_qp_api    ( p_event_num      IN   NUMBER,
--                           x_return_status  OUT  VARCHAR2);

PROCEDURE   call_qp_api  ( x_qp_output_line_rows    OUT NOCOPY  QP_PREQ_GRP.LINE_TBL_TYPE,
                           x_qp_output_detail_rows  OUT NOCOPY  QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE,
                           x_return_status          OUT NOCOPY   VARCHAR2);


-- return the pointer to the qp outputs
PROCEDURE get_qp_output(
  x_qp_output_line_rows    OUT NOCOPY  QP_PREQ_GRP.LINE_TBL_TYPE,
  x_qp_output_detail_rows  OUT NOCOPY  QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE,
  x_return_status OUT NOCOPY  VARCHAR2);

-- other utility methods ---

 -- this procedure calculates the total base price of a shipment, for a given set.
 -- multiplies unit price by line quantity
 -- price is in the priced currency

 PROCEDURE get_total_base_price       (p_set_num          IN NUMBER DEFAULT 1,
                                       -- x_priced_currency  OUT NUMBER,
                                       x_price            OUT NOCOPY  NUMBER,
                                       x_return_status    OUT NOCOPY  VARCHAR2);

-- prorate (apply) new charge across engine output lines by ratio of current unit_price to current total unit price?
-- ( it could also be by ratio of current line amount to current total base price)
-- assumes that the new price is in the priced currency.
 PROCEDURE apply_new_base_price       (p_set_num          IN NUMBER  DEFAULT 1,
                                       p_new_total_price  IN NUMBER,
                                       x_return_status    OUT NOCOPY  VARCHAR2);


-- copies input lines of one event to the input of another event
-- the base prices from the source event are carried over to the input of the target event
-- currently it will copy only from event 1 to event 2
 PROCEDURE prepare_next_event_request ( x_return_status    OUT NOCOPY  VARCHAR2);

   -- get me unit price for each individual commodity for each set
  -- get me total wt. for each individual commodity
  -- give me all weights in the deficit wt uom
  -- currently we have implementation only for event num =1
 PROCEDURE analyse_output_for_deficit_wt (p_set_num          IN NUMBER,
                                          p_wt_uom           IN VARCHAR2,
                                          x_commodity_price_rows  OUT NOCOPY  commodity_price_tbl_type,
                                          x_return_status    OUT NOCOPY  VARCHAR2);

 -- delete a set from the input and output lines for event 1
 PROCEDURE delete_set_from_line_event(p_set_num          IN NUMBER,
                                      x_return_status    OUT NOCOPY  VARCHAR2);



 -- delete from event tables for the specified line_index
 --PROCEDURE delete_lines(p_event_num IN NUMBER DEFAULT 1,
 --                       p_line_index IN NUMBER,
 --                       x_return_status    OUT VARCHAR2);

PROCEDURE delete_lines(p_line_index      IN NUMBER,
                       x_qp_output_line_rows    IN OUT NOCOPY  QP_PREQ_GRP.LINE_TBL_TYPE,
                       x_qp_output_detail_rows  IN OUT NOCOPY  QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE,
                       x_return_status   OUT NOCOPY  VARCHAR2);

-- clear qp input line table, line extra table, attribute/qualifier tabl
PROCEDURE clear_qp_input(x_return_status OUT NOCOPY  VARCHAR2);

 --debug methods

PROCEDURE print_qp_input;

PROCEDURE print_qp_output;

PROCEDURE check_qp_output_errors (x_return_status  OUT NOCOPY  VARCHAR2);

PROCEDURE check_tl_qp_output_errors (x_return_status  OUT NOCOPY  VARCHAR2);

PROCEDURE check_parcel_output_errors (p_event_num      IN NUMBER,
                                      x_return_code    OUT NOCOPY  NUMBER,
                                      x_return_status  OUT NOCOPY  VARCHAR2);

PROCEDURE clear_globals (
  x_return_status OUT NOCOPY VARCHAR2);

END FTE_QP_ENGINE;

 

/
