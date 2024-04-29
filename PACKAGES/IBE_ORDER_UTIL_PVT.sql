--------------------------------------------------------
--  DDL for Package IBE_ORDER_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_ORDER_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: IBEVOUTS.pls 120.3 2005/11/27 13:43:52 susinha noship $ */

	PROCEDURE Get_Ord_Recurring_totals
	 ( p_header_id              		IN NUMBER,
	   x_charge_periodicity_code        OUT NOCOPY JTF_VARCHAR2_TABLE_300,
	   x_charge_periodicity_desc        OUT NOCOPY JTF_VARCHAR2_TABLE_300,
	   x_charge_periodicity_meaning     OUT NOCOPY JTF_VARCHAR2_TABLE_300,
	   x_rec_subtotal        		    OUT NOCOPY JTF_NUMBER_TABLE,
	   x_rec_tax        			    OUT NOCOPY JTF_NUMBER_TABLE,
	   x_rec_charges        		    OUT NOCOPY JTF_NUMBER_TABLE,
	   x_rec_total        			    OUT NOCOPY JTF_NUMBER_TABLE,
	   X_return_status         	   	    OUT NOCOPY VARCHAR2,
	   X_msg_count             		    OUT NOCOPY NUMBER,
	   X_msg_data              		    OUT NOCOPY VARCHAR2
	  );


	PROCEDURE Get_Adjustments(
		x_adjustment_name                OUT NOCOPY JTF_VARCHAR2_TABLE_300 ,
		x_adjustment_description         OUT NOCOPY JTF_VARCHAR2_TABLE_2000 ,
		x_list_line_no              OUT NOCOPY JTF_VARCHAR2_TABLE_300 ,
		x_adjustment_type_code                OUT NOCOPY JTF_VARCHAR2_TABLE_300 ,
		x_arithmetic_operator                OUT NOCOPY JTF_VARCHAR2_TABLE_300 ,
		x_return_status             OUT NOCOPY VARCHAR2,
		p_header_id                  IN NUMBER:= FND_API.G_MISS_NUM,
		p_line_id                     IN NUMBER:= FND_API.G_MISS_NUM,
		x_price_adjustment_id          OUT NOCOPY jtf_number_table     ,
		x_operand          OUT NOCOPY jtf_number_table     ,
		x_unit_discount_amount          OUT NOCOPY jtf_number_table,
		x_count_lines			OUT NOCOPY NUMBER

		);



       PROCEDURE Get_MACD_Action_Mode
	       ( p_header_id              	   IN  NUMBER,
	         x_top_model_line_id               OUT NOCOPY  JTF_NUMBER_TABLE,
	         x_line_is_reconfig                OUT NOCOPY JTF_VARCHAR2_TABLE_100,
                 x_return_status                   OUT NOCOPY VARCHAR2
	        );

       -- Function to get the PRIMARY Phone and Email for the iStore Party
	  -- i.e For Party-Type=B2C, get for party of type PERSON (pass person_party_id)
	  --     For Party-Type=B2B, get for party of type PARTY_RELATIONSHIP(pass party_id of type party_relationship)
       FUNCTION GET_PHONE_EMAIL
       (   p_party_id                      IN  NUMBER
       ) RETURN VARCHAR2;


       --  The following procudure verifies whether the last_updated_date passed is
       -- older than the last_updated_date present in the DB

        PROCEDURE  validate_last_update_date
        (p_header_id IN NUMBER,
         p_last_update_date IN DATE,
         x_is_diff_last_update  OUT NOCOPY VARCHAR2);


END IBE_ORDER_UTIL_PVT;

 

/
