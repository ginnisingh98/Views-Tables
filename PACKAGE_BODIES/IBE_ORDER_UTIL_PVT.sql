--------------------------------------------------------
--  DDL for Package Body IBE_ORDER_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_ORDER_UTIL_PVT" AS
/* $Header: IBEVOUTB.pls 120.6 2006/06/15 09:14:39 akhgupta noship $ */


l_true VARCHAR2(1)                := FND_API.G_TRUE;

PROCEDURE Get_Ord_Recurring_totals
(
  p_header_id              		IN NUMBER,
  x_charge_periodicity_code        OUT NOCOPY JTF_VARCHAR2_TABLE_300,
  x_charge_periodicity_desc        OUT NOCOPY JTF_VARCHAR2_TABLE_300,
  x_charge_periodicity_meaning     OUT NOCOPY JTF_VARCHAR2_TABLE_300,
  x_rec_subtotal        		    OUT NOCOPY JTF_NUMBER_TABLE,
  x_rec_tax        			    OUT NOCOPY JTF_NUMBER_TABLE,
  x_rec_charges        		    OUT NOCOPY JTF_NUMBER_TABLE,
  x_rec_total        			    OUT NOCOPY JTF_NUMBER_TABLE,
  x_return_status         	   	    OUT NOCOPY VARCHAR2,
  x_msg_count             		    OUT NOCOPY NUMBER,
  x_msg_data              		    OUT NOCOPY VARCHAR2
	  )

IS

l_rec_charge_tbl OE_OE_TOTALS_SUMMARY.Rec_Charges_Tbl_Type;

BEGIN
    x_charge_periodicity_code := JTF_VARCHAR2_TABLE_300();
    x_charge_periodicity_desc := JTF_VARCHAR2_TABLE_300();
    x_charge_periodicity_meaning := JTF_VARCHAR2_TABLE_300();
    x_rec_subtotal := JTF_NUMBER_TABLE();
    x_rec_tax := JTF_NUMBER_TABLE();
    x_rec_charges := JTF_NUMBER_TABLE();
    x_rec_total := JTF_NUMBER_TABLE();

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('In Get_Ord_Recurring_totals : After Initializations. Calling OE_Totals_GRP.GET_RECURRING_TOTALS');
    END IF;

    OE_Totals_GRP.GET_RECURRING_TOTALS
        (
        p_header_id => p_header_id,
        x_rec_charges_tbl => l_rec_charge_tbl
         );

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('In Get_Ord_Recurring_totals : Returned from OE_Totals_GRP.GET_RECURRING_TOTALS');
    END IF;

    IF(l_rec_charge_tbl is not null) THEN

        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_Util.Debug('In Get_Ord_Recurring_totals : Count :: '||l_rec_charge_tbl.count);
        END IF;

        FOR n IN l_rec_charge_tbl.first .. l_rec_charge_tbl.last LOOP
            x_charge_periodicity_code.EXTEND();
            x_charge_periodicity_code(n) := l_rec_charge_tbl(n).charge_periodicity_code;
            x_charge_periodicity_desc.EXTEND();
            x_charge_periodicity_desc(n) := l_rec_charge_tbl(n).charge_periodicity_desc;
            x_charge_periodicity_meaning.EXTEND();
            x_charge_periodicity_meaning(n) := l_rec_charge_tbl(n).charge_periodicity_meaning;
            x_rec_subtotal.EXTEND();
            x_rec_subtotal(n) := l_rec_charge_tbl(n).rec_subtotal;
            x_rec_tax.EXTEND();
            x_rec_tax(n) := l_rec_charge_tbl(n).rec_tax;
            x_rec_charges.EXTEND();
            x_rec_charges(n) := l_rec_charge_tbl(n).rec_charges;
            x_rec_total.EXTEND();
            x_rec_total(n) := l_rec_charge_tbl(n).rec_total;
        END LOOP;
    END IF;

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('In Get_Ord_Recurring_totals : End');
    END IF;

END Get_Ord_Recurring_totals;



PROCEDURE Get_Adjustments(
  x_adjustment_name                OUT NOCOPY JTF_VARCHAR2_TABLE_300 ,
  x_adjustment_description         OUT NOCOPY JTF_VARCHAR2_TABLE_2000 ,
  x_list_line_no              OUT NOCOPY JTF_VARCHAR2_TABLE_300 ,
  x_adjustment_type_code                OUT NOCOPY JTF_VARCHAR2_TABLE_300 ,
  x_arithmetic_operator                OUT NOCOPY JTF_VARCHAR2_TABLE_300 ,
  x_return_status             OUT NOCOPY VARCHAR2,
  p_header_id                  IN NUMBER,
  p_line_id                     IN NUMBER,
  x_price_adjustment_id          OUT NOCOPY jtf_number_table     ,
  x_operand          OUT NOCOPY jtf_number_table     ,
  x_unit_discount_amount          OUT NOCOPY jtf_number_table,
  x_count_lines        OUT NOCOPY number
)IS

        l_adj_detail_tbl  OE_Header_Adj_Util.line_adjustments_tab_type ;


BEGIN
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
              IBE_Util.Debug('In Get_Adjustments : Start');
        END IF;
        x_price_adjustment_id        := JTF_NUMBER_TABLE();
           x_adjustment_name            := JTF_VARCHAR2_TABLE_300();
        x_adjustment_description     := JTF_VARCHAR2_TABLE_2000();
           x_list_line_no               := JTF_VARCHAR2_TABLE_300();
           x_adjustment_type_code       := JTF_VARCHAR2_TABLE_300();
                x_operand        := JTF_NUMBER_TABLE();
           x_arithmetic_operator        := JTF_VARCHAR2_TABLE_300();
           x_unit_discount_amount       := JTF_NUMBER_TABLE();

        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('In Get_Adjustments : After Initializations. Calling oe_lineinfo_grp.Get_Adjustments');
        END IF;

           OE_LineInfo_Grp.Get_Adjustments(
               p_header_id   => p_header_id,
               p_line_id      => p_line_id,
           x_adj_detail  =>  l_adj_detail_tbl,
               x_return_status => x_return_status
        );

        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
              IBE_Util.Debug('In Get_Adjustments : After Call to oe_lineinfo_grp.Get_Adjustments');
        END IF;

        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('In Get_Adjustments : Indexes of l_adj_detail_tbl Fist : '||l_adj_detail_tbl.first || ' Last : ' || l_adj_detail_tbl.last);
        END IF;
        x_count_lines:=l_adj_detail_tbl.count();
        for n in l_adj_detail_tbl.first .. l_adj_detail_tbl.last LOOP
             x_price_adjustment_id.EXTEND();
            x_price_adjustment_id (n)   := l_adj_detail_tbl(n).price_adjustment_id ;
            x_adjustment_name.EXTEND();
            x_adjustment_name (n)       := l_adj_detail_tbl(n).adjustment_name ;
            x_adjustment_description.EXTEND();
            x_adjustment_description (n)       := l_adj_detail_tbl(n).adjustment_description ;
            x_list_line_no.EXTEND();
            x_list_line_no(n)           := l_adj_detail_tbl(n).list_line_no;
                x_adjustment_type_code.EXTEND();
                x_adjustment_type_code(n)   := l_adj_detail_tbl(n).adjustment_type_code;
            x_operand.EXTEND();
            x_operand(n)               := l_adj_detail_tbl(n).operand;
            x_arithmetic_operator.EXTEND();
            x_arithmetic_operator(n)    := l_adj_detail_tbl(n).arithmetic_operator;
                x_unit_discount_amount.EXTEND();
                x_unit_discount_amount(n)   := l_adj_detail_tbl(n).unit_discount_amount;
        END LOOP;

           IF (IBE_UTIL.G_DEBUGON = l_true) THEN
              IBE_Util.Debug('In Get_Adjustments : End');
        END IF;
END Get_Adjustments;



     -- Procedure to get whether the top models are reconfigured or not fiven a header id

 -- Procedure to get whether the top models are reconfigured or not fiven a header id
     PROCEDURE Get_MACD_Action_Mode
           ( p_header_id                     IN  NUMBER,
             x_top_model_line_id               OUT NOCOPY  JTF_NUMBER_TABLE,
             x_line_is_reconfig                OUT NOCOPY JTF_VARCHAR2_TABLE_100,
                 x_return_status                   OUT NOCOPY VARCHAR2
      )IS
 -- Define the variables
    l_top_model_line_id   NUMBER;
        l_line_id             number;
    l_config_mode         NUMBER;
           l_return_status       VARCHAR2(1);
    l_index Number  := 1;


-- Find all the top model line ids of type container.

     CURSOR  c_top_model(c_header_id NUMBER ) IS
     SELECT    oel.line_id, oel.top_model_line_id
     FROM      oe_order_lines_all oel
     WHERE    oel.top_model_line_id = oel.line_id
     AND      oel.link_to_line_id is null
     AND      oel.header_id  = c_header_id;

      BEGIN

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
              IBE_Util.Debug('In Get_MACD_Action_Mode : Start');
      END IF;

      x_top_model_line_id   := JTF_NUMBER_TABLE();
      x_line_is_reconfig    := JTF_VARCHAR2_TABLE_100();

      OPEN c_top_model(P_header_id);
      LOOP
         FETCH c_top_model INTO l_line_id ,l_top_model_line_id;

               IF (IBE_UTIL.G_DEBUGON = l_true) THEN
              IBE_Util.Debug('In Get_MACD_Action_Mode : l_top_model_line_id:' ||l_top_model_line_id);
               END IF;


         EXIT WHEN c_top_model%NOTFOUND;

         /*Call the OE procedure to check that the line is reconfigured or not
           If the value of l_config_mode  in (2,3 4) , the model is reconfigred. */

         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_Util.Debug('In Get_MACD_Action_Mode : After Initializations. Calling OE_CONFIG_TSO_GRP.Get_MACD_Action_Mode');
         END IF;




         OE_CONFIG_TSO_GRP.Get_MACD_Action_Mode
              ( p_line_id             =>  l_line_id,
                        p_top_model_line_id  =>  l_top_model_line_id ,
                x_config_mode         => l_config_mode,
                x_return_status       => l_return_status
               );

         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_Util.Debug('In Get_MACD_Action_Mode : After Calling OE_CONFIG_TSO_GRP.Get_MACD_Action_Mode');
         END IF;



         -- if the l_config_mode = 2,3, 4 then the line is a reconfigured one

         if (l_config_mode IS NOT NULL) AND (l_config_mode IN (2,3, 4) ) then

                x_top_model_line_id.extend();
                x_top_model_line_id(l_index) := l_top_model_line_id;
                    x_line_is_reconfig.extend();
                x_line_is_reconfig(l_index)  := 'Y' ;


               IF (IBE_UTIL.G_DEBUGON = l_true) THEN
              IBE_Util.Debug('In Get_MACD_Action_Mode : x_top_model_line_id(l_index) :' || x_top_model_line_id(l_index) );
                        IBE_Util.Debug('In Get_MACD_Action_Mode : x_line_is_reconfig(l_index) :' || x_line_is_reconfig(l_index) );
               END IF;

               l_index := l_index +1;

        end if;




      END LOOP;
      CLOSE c_top_model;

       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('In Get_Adjustments : End');
       END IF;

    END  Get_MACD_Action_Mode;



    -- Function to retrieve phone and email given a party id

    FUNCTION GET_PHONE_EMAIL
    (   p_party_id                      IN  NUMBER
    ) RETURN VARCHAR2
    IS

    l_api_name                    CONSTANT VARCHAR2(30):= 'Get_Phone_Email';

       CURSOR c_contact_details(c_party_id number) IS
          select phone_country_code,phone_area_code,phone_number,phone_extension,
                 contact_point_type, primary_flag,phone_line_type,
                 email_address
          from   hz_contact_points
          where contact_point_type in ('PHONE','EMAIL') and
          NVL(status, 'A') = 'A'
          and owner_table_name = 'HZ_PARTIES'
          and owner_table_id = c_party_id
          and primary_flag='Y';

    lc_contact_details c_contact_details%rowtype;
    l_cntct_phone_country_code VARCHAR2(20)  := '';
    l_cntct_phone_area_code    VARCHAR2(20)  := '';
    l_cntct_phone_number       VARCHAR2(20)  := '';
    l_cntct_phone_extn         VARCHAR2(20)  := '';
    L_CNTCT_PHONE              VARCHAR2(100)  := '';
    l_cntct_email              VARCHAR2(1000) := '';
    BEGIN

       -- FETCH EMAIL and Phone
     if p_party_id is null  then
        l_cntct_phone       := '';
        l_cntct_email       := '';
     else
        open c_contact_details(p_party_id);
        loop
          fetch c_contact_details into lc_contact_details;
          Exit When c_contact_details%notfound;
          IF lc_contact_details.CONTACT_POINT_TYPE = 'EMAIL' THEN
            l_cntct_email := lc_contact_details.EMAIL_ADDRESS;
          ELSE
            IF (lc_contact_details.CONTACT_POINT_TYPE = 'PHONE') THEN
               l_cntct_phone :=  IBE_UTIL.format_phone(lc_contact_details.PHONE_COUNTRY_CODE,lc_contact_details.PHONE_AREA_CODE,
                                                       lc_contact_details.PHONE_NUMBER,lc_contact_details.PHONE_EXTENSION );
            END IF;
          END IF;
        end loop;
        close c_contact_details;
     end if;

     -- Concatenate phone and email with a delimiter parse it in jsp
     RETURN (l_cntct_phone || '[({})]' || l_cntct_email );

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN '';
        WHEN OTHERS THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END Get_Phone_Email;


  /*  The following procudure verifies whether the last_updated_date passed is older than the
  last_updated_date present in the DB */


  PROCEDURE  validate_last_update_date
  (p_header_id IN NUMBER,
   p_last_update_date IN DATE,
   x_is_diff_last_update  OUT NOCOPY VARCHAR2)

IS
  CURSOR c_getLastUpdatedDate(p_header_id NUMBER) IS
    SELECT last_update_date FROM oe_order_headers_all WHERE header_id = p_header_id;


  l_getLastUpdatedDate  c_getLastUpdatedDate%rowtype;
  l_is_diff_last_update  VARCHAR2(1) := 'F';


BEGIN
      IBE_Util.Debug('In validate_last_update_date : start' );

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('In validate_last_update_date : After Initializations');
    END IF;

    --
    OPEN c_getLastUpdatedDate(p_header_id);
    FETCH c_getLastUpdatedDate INTO l_getLastUpdatedDate;
     IF (c_getLastUpdatedDate%NOTFOUND) THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('No order with this header id, it is cancelled');
    END IF;
         l_is_diff_last_update := 'T';
     ELSIF (l_getLastUpdatedDate.last_update_date > p_last_update_date) THEN
          l_is_diff_last_update := 'T';
     ELSE
          l_is_diff_last_update := 'F';
     END IF;
  CLOSE c_getLastUpdatedDate;

   x_is_diff_last_update :=  l_is_diff_last_update;
   IBE_Util.Debug('In validate_last_update_date : End' || x_is_diff_last_update );

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('In validate_last_update_date : End');
    END IF;

END validate_last_update_date;


END IBE_ORDER_UTIL_PVT;

/
