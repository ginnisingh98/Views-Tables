--------------------------------------------------------
--  DDL for Package Body PV_OFFER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_OFFER_PUB" as
/* $Header: pvxvoffb.pls 115.9 2004/08/09 21:34:50 amaram ship $*/

/*************************************************************************************/
/*                                                                                   */
/*                                                                                   */
/*                                                                                   */
/*                    Global Variable Declaration                                    */
/*                                                                                   */
/*                                                                                   */
/*                                                                                   */
/*************************************************************************************/
g_pkg_name           VARCHAR2(30) := 'PV_OFFER_PUB';
g_api_name           VARCHAR2(30);

PV_DEBUG_HIGH_ON boolean :=
   FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
PV_DEBUG_LOW_ON boolean :=
   FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
PV_DEBUG_MEDIUM_ON boolean :=
   FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);
PV_DEBUG_ERROR_ON boolean :=
   FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_ERROR);


/*************************************************************************************/
/*                                                                                   */
/*                                                                                   */
/*                                                                                   */
/*                    private procedure declaration                                  */
/*                                                                                   */
/*                                                                                   */
/*                                                                                   */
/*************************************************************************************/
PROCEDURE Debug(
   p_msg_string      IN VARCHAR2,
   p_msg_type        IN VARCHAR2 := 'PV_DEBUG_MESSAGE',
   p_token_type      IN VARCHAR2 := 'TEXT',
   p_statement_level IN NUMBER   := FND_LOG.LEVEL_PROCEDURE
);

PROCEDURE Set_Message(
    p_msg_name      IN      VARCHAR2,
    p_token1        IN      VARCHAR2 := NULL,
    p_token1_value  IN      VARCHAR2 := NULL,
    p_token2        IN      VARCHAR2 := NULL,
    p_token2_value  IN      VARCHAR2 := NULL,
    p_token3        IN      VARCHAR2 := NULL,
    p_token3_value  IN      VARCHAR2 := NULL,
    p_statement_level IN NUMBER   := FND_LOG.LEVEL_PROCEDURE
);



--=============================================================================+
--| Public Procedure                                                           |
--|    Create_Offer                                                            |
--|                                                                            |
--| Parameters                                                                 |
--|    IN                                                                      |
--|    OUT                                                                     |
--|                                                                            |
--|                                                                            |
--| NOTES                                                                      |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
PROCEDURE create_offer(
   p_init_msg_list         IN  VARCHAR2,
   p_api_version           IN  NUMBER,
   p_commit                IN  VARCHAR2,
   p_benefit_id            IN  NUMBER,
   p_operation             IN  VARCHAR2,
   p_offer_id              IN  NUMBER,
   p_modifier_list_rec     IN  modifier_list_rec_type,
   p_budget_tbl            IN  budget_tbl_type,
   p_discount_tbl          IN  discount_line_tbl_type,
   p_na_qualifier_tbl      IN  na_qualifier_tbl_type,
   x_offer_id              OUT NOCOPY NUMBER,
   x_qp_list_header_id     OUT NOCOPY NUMBER,
   x_error_location        OUT NOCOPY NUMBER,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2
)
IS
   lp_budget_tbl          ozf_offer_pub.budget_tbl_type;
   lp_discount_tbl        ozf_offer_pub.discount_line_tbl_type;
   lp_na_qualifier_tbl    ozf_offer_pub.na_qualifier_tbl_type;

   l_modifier_line_tbl    ozf_offer_pub.modifier_line_tbl_type;
   l_qualifier_tbl        ozf_offer_pub.qualifiers_tbl_type;
   l_act_product_tbl      ozf_offer_pub.act_product_tbl_type;
   l_excl_tbl             ozf_offer_pub.excl_rec_tbl_type;
   l_offer_tier_tbl       ozf_offer_pub.offer_tier_tbl_type;
   l_prod_tbl             ozf_offer_pub.prod_rec_tbl_type;


   l_modifier_list_rec    ozf_offer_pub.modifier_list_rec_type;
   l_empty_modifier_list_rec ozf_offer_pub.modifier_list_rec_type;
   l_budget_tbl           ozf_offer_pub.budget_tbl_type;
   l_discount_tbl         ozf_offer_pub.discount_line_tbl_type;
   l_na_qualifier_tbl     ozf_offer_pub.na_qualifier_tbl_type;

   l_profile_value        VARCHAR2(50);

   -- ----------------------------------------------------------------
   -- Used for deleting offer-related items.
   -- ----------------------------------------------------------------
   l_qp_list_header_id        NUMBER;
   l_del_modifier_list_rec    ozf_offer_pub.modifier_list_rec_type;
   l_del_budget_tbl           ozf_offer_pub.budget_tbl_type;
   l_del_discount_tbl         ozf_offer_pub.discount_line_tbl_type;
   l_del_na_qualifier_tbl     ozf_offer_pub.na_qualifier_tbl_type;
   i                          NUMBER;

   ----------------------------
   --used for bug# 3738487
   --------------------------
  j                         NUMBER;
  l_budget_id_table			JTF_NUMBER_TABLE;
  budget_id_found           VARCHAR2(1);
  k                         NUMBER;

BEGIN
   g_api_name := 'Create_Offer';

   Debug('p_operation: ' || p_operation);

   IF (p_operation NOT IN ('UPDATE', 'CREATE')) THEN
      Debug('Wrong p_operation type: ' || p_operation);
      Debug('p_operation must be either ''UPDATE'' or ''CREATE''');
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- ---------------------------------------------------------------
   -- Check profile "OZF: Validate market and product eligibility
   -- between object and budget". Referral offer must have budget
   -- validation done.
   -- The profile must have the value "Validate customer and products
   -- by each budget"
   -- ---------------------------------------------------------------
   l_profile_value := FND_PROFILE.VALUE('OZF_CHECK_MKTG_PROD_ELIG');

   IF (l_profile_value <> 'PRODUCT_STRICT_CUSTOMER_STRICT') THEN
      Set_Message(
         p_msg_name      => 'PV_SET_BUDGET_VALIDATION'
      );

      RAISE FND_API.G_EXC_ERROR;
   END IF;


   -- =============================================================== --
   -- =============================================================== --
   --                      UPDATE OPERATION                           --
   -- =============================================================== --
   -- =============================================================== --
   -- ---------------------------------------------------------------
   -- 'UPDATE' indicates that the offer already exists but some of
   -- the items related to the offer (e.g. products, territories,
   -- or budgets) require modification/addition.  The easiest way
   -- to this is to just delete all the items related to the offer
   -- and re-create them.
   -- ---------------------------------------------------------------
   IF (p_operation = 'UPDATE' AND p_offer_id IS NULL) THEN
      Debug('Offer ID must be provided when the operation is UPDATE.');
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- ---------------------------------------------------------------
   -- 'UPDATE' indicates that the offer already exists but some of
   -- the items related to the offer (e.g. products, territories,
   -- or budgets) require modification/addition.  The easiest way
   -- to this is to just delete all the items related to the offer
   -- and re-create them.
   -- ---------------------------------------------------------------
   IF (p_operation = 'UPDATE') THEN
      -- ----------------------------------------------------------
      -- l_del_modifier_list_rec
      -- ----------------------------------------------------------
      FOR x IN (SELECT qp_list_header_id
                FROM   ozf_offers
                WHERE  offer_id = p_offer_id)
      LOOP
         l_qp_list_header_id                        := x.qp_list_header_id;
         l_del_modifier_list_rec.QP_LIST_HEADER_ID  := x.qp_list_header_id;
         l_del_modifier_list_rec.offer_operation    := 'DELETE';
         l_del_modifier_list_rec.user_status_id     := 1600;
      END LOOP;

      -- ----------------------------------------------------------
      -- Deleting Discount/Product Lines
      -- ----------------------------------------------------------
      i := 1;
      FOR x IN (SELECT a.offer_discount_line_id,
                       a.object_version_number,
                       b.off_discount_product_id
                FROM   ozf_offer_discount_lines  a,
                       ozf_discount_product_reln b
                WHERE  a.offer_discount_line_id = b.offer_discount_line_id AND
                       a.offer_id               = p_offer_id)
      LOOP
         l_del_discount_tbl(i).offer_discount_line_id  := x.offer_discount_line_id;
         l_del_discount_tbl(i).operation               := 'DELETE';
         l_del_discount_tbl(i).object_version_number   := x.object_version_number;
         l_del_discount_tbl(i).off_discount_product_id := x.off_discount_product_id;
         i := i + 1;
      END LOOP;

      -- ----------------------------------------------------------
      -- Deleting Territory/Marketing Eligibility Qualifiers
      -- ----------------------------------------------------------
      i := 1;
      FOR x IN (SELECT qualifier_id, object_version_number
                FROM   ozf_offer_qualifiers
                WHERE  offer_id = p_offer_id)
      LOOP
         l_del_na_qualifier_tbl(i).Qualifier_id          := x.qualifier_id;
         l_del_na_qualifier_tbl(i).operation             := 'DELETE';
         l_del_na_qualifier_tbl(i).object_version_number := x.object_version_number;
         i := i + 1;
      END LOOP;


      -- ----------------------------------------------------------
      -- Deleting Budget Request
      -- ----------------------------------------------------------

	  -- If benefit failed validation and the user tries to re-activate it, delete
	  -- from ozf budget requests only records that are not in APPROVED status. when
	  -- recreating the offer, add only records from PV that are not in APPROVED status.
	  -- for bug# 3738487


	  l_budget_id_table  := JTF_NUMBER_TABLE();

      i := 1;
	  j := 1;
      FOR x IN (SELECT activity_budget_id, status_code, budget_source_id
                FROM   ozf_act_budgets
                WHERE  arc_act_budget_used_by = 'OFFR' AND
                       act_budget_used_by_id  = l_qp_list_header_id)
      LOOP
         if(x.status_code ='APPROVED' ) then
			l_budget_id_table.extend();
			l_budget_id_table(j) := x.budget_source_id;
			j := j + 1;
		 else
			l_del_budget_tbl(i).act_budget_id := x.activity_budget_id;
			l_del_budget_tbl(i).operation     := 'DELETE';
			i := i + 1;
		 end if;

      END LOOP;

      -- ----------------------------------------------------------
      -- Delete Offer-related Items
      -- ----------------------------------------------------------
      Debug('Deleting offer-related items..........................');

      ozf_offer_pub.process_modifiers(
         p_init_msg_list         => FND_API.g_false,
         p_api_version           => 1.0,
         p_commit                => FND_API.g_false,
         x_return_status         => x_return_status,
         x_msg_count             => x_msg_count,
         x_msg_data              => x_msg_data,
         p_offer_type            => 'NET_ACCRUAL',
         p_modifier_list_rec     => l_del_modifier_list_rec,
         p_modifier_line_tbl     => l_modifier_line_tbl,
         p_qualifier_tbl         => l_qualifier_tbl,
         p_budget_tbl            => l_del_budget_tbl,
         p_act_product_tbl       => l_act_product_tbl,
         p_discount_tbl          => l_del_discount_tbl,
         p_excl_tbl              => l_excl_tbl,
         p_offer_tier_tbl        => l_offer_tier_tbl,
         p_prod_tbl              => l_prod_tbl,
         p_na_qualifier_tbl      => l_del_na_qualifier_tbl,
         x_qp_list_header_id     => l_qp_list_header_id,
         x_error_location        => x_error_location
      );

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR;

      ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

   END IF;

   -- =============================================================== --
   -- =============================================================== --
   --                    END UPDATE OPERATION                         --
   -- =============================================================== --
   -- =============================================================== --


   IF (p_operation = 'CREATE') THEN
      l_modifier_list_rec.description        := p_modifier_list_rec.description;
      l_modifier_list_rec.comments           := p_modifier_list_rec.comments;
      l_modifier_list_rec.offer_code         := p_modifier_list_rec.offer_code;
      l_modifier_list_rec.currency_code      := p_modifier_list_rec.currency_code;
      l_modifier_list_rec.budget_amount_tc   := p_modifier_list_rec.budget_amount_tc;

      l_modifier_list_rec.offer_operation    := 'CREATE';
      l_modifier_list_rec.modifier_operation := 'CREATE';
      l_modifier_list_rec.tier_level         := 'LINE';
      l_modifier_list_rec.status_code        := 'DRAFT';
      l_modifier_list_rec.user_status_id     := 1600;
      l_modifier_list_rec.offer_type         := 'NET_ACCRUAL';
      l_modifier_list_rec.custom_setup_id    := 105;
      l_modifier_list_rec.start_date_active  := SYSDATE;

      -- Feng Liu asked this be added 2/20/04
      l_modifier_list_rec.reusable           := 'N';

   ELSIF (p_operation = 'UPDATE') THEN
      Debug('l_qp_list_header_id: ' || l_qp_list_header_id);
      l_modifier_list_rec.currency_code      := p_modifier_list_rec.currency_code;
      l_modifier_list_rec.budget_amount_tc   := p_modifier_list_rec.budget_amount_tc;

      l_modifier_list_rec.offer_operation    := 'UPDATE';
      l_modifier_list_rec.QP_LIST_HEADER_ID  := l_qp_list_header_id;
      l_modifier_list_rec.user_status_id     := 1600;
   END IF;

   --adding this if loop for bug# 3738487
   k := 1;
   IF (p_operation = 'UPDATE') THEN
		FOR i IN 1..p_budget_tbl.COUNT LOOP
			budget_id_found := 'N';
			FOR j IN 1..l_budget_id_table.COUNT LOOP
				if(p_budget_tbl(i).budget_id = l_budget_id_table(j)) then
					budget_id_found := 'Y';
					exit;
				end if;

			END LOOP;

			if (budget_id_found <> 'Y') then

				lp_budget_tbl(k).act_budget_id := p_budget_tbl(i).act_budget_id;
				lp_budget_tbl(k).budget_id     := p_budget_tbl(i).budget_id;
				lp_budget_tbl(k).budget_amount := p_budget_tbl(i).budget_amount;
				lp_budget_tbl(k).operation     := p_budget_tbl(i).operation;

				Debug('lp_budget_tbl(' || k || ').act_budget_id = ' || lp_budget_tbl(k).act_budget_id);
				Debug('lp_budget_tbl(' || k || ').budget_id = ' || lp_budget_tbl(k).budget_id);
				Debug('lp_budget_tbl(' || k || ').budget_amount = ' || lp_budget_tbl(k).budget_amount);
				Debug('lp_budget_tbl(' || k || ').operation = ' || lp_budget_tbl(k).operation);
				k := k +1 ;
		    end if;
			budget_id_found := 'N';
		END LOOP;

   ELSIF (p_operation = 'CREATE') THEN

	   -- ---------------------------------------------------------------
	   -- Assign PV type variables to OZF type variables.
	   -- ---------------------------------------------------------------
	   Debug('Printing out budget request parameters.......................');
	   FOR i IN 1..p_budget_tbl.COUNT LOOP
		  lp_budget_tbl(i).act_budget_id := p_budget_tbl(i).act_budget_id;
		  lp_budget_tbl(i).budget_id     := p_budget_tbl(i).budget_id;
		  lp_budget_tbl(i).budget_amount := p_budget_tbl(i).budget_amount;
		  lp_budget_tbl(i).operation     := p_budget_tbl(i).operation;

		  Debug('lp_budget_tbl(' || i || ').act_budget_id = ' || lp_budget_tbl(i).act_budget_id);
		  Debug('lp_budget_tbl(' || i || ').budget_id = ' || lp_budget_tbl(i).budget_id);
		  Debug('lp_budget_tbl(' || i || ').budget_amount = ' || lp_budget_tbl(i).budget_amount);
		  Debug('lp_budget_tbl(' || i || ').operation = ' || lp_budget_tbl(i).operation);
	   END LOOP;
   END IF;

   FOR i IN 1..p_discount_tbl.COUNT LOOP
      lp_discount_tbl(i).offer_discount_line_id  := p_discount_tbl(i).offer_discount_line_id;
      lp_discount_tbl(i).parent_discount_line_id := p_discount_tbl(i).parent_discount_line_id;
      lp_discount_tbl(i).discount                := p_discount_tbl(i).discount;
      lp_discount_tbl(i).discount_type           := p_discount_tbl(i).discount_type;
      lp_discount_tbl(i).tier_type               := p_discount_tbl(i).tier_type;
      lp_discount_tbl(i).tier_level              := p_discount_tbl(i).tier_level;
      lp_discount_tbl(i).object_version_number   := p_discount_tbl(i).object_version_number;
      lp_discount_tbl(i).product_level           := p_discount_tbl(i).product_level;
      lp_discount_tbl(i).product_id              := p_discount_tbl(i).product_id;
      lp_discount_tbl(i).operation               := p_discount_tbl(i).operation;
   END LOOP;

   FOR i IN 1..p_na_qualifier_tbl.COUNT LOOP
      lp_na_qualifier_tbl(i).qualifier_id          := p_na_qualifier_tbl(i).qualifier_id;
      lp_na_qualifier_tbl(i).qualifier_context     := p_na_qualifier_tbl(i).qualifier_context;
      lp_na_qualifier_tbl(i).qualifier_attribute   := p_na_qualifier_tbl(i).qualifier_attribute;
      lp_na_qualifier_tbl(i).qualifier_attr_value  := p_na_qualifier_tbl(i).qualifier_attr_value;
      lp_na_qualifier_tbl(i).object_version_number := p_na_qualifier_tbl(i).object_version_number;
      lp_na_qualifier_tbl(i).operation             := p_na_qualifier_tbl(i).operation;

      -- ---------------------------------------------------------------------------
      -- Within an offer, if qualifier_grouping_no is the same for all qualifiers,
      -- it's an AND condition. That is, it has to meet all qualifiers to be
      -- considered qualifier_grouping_no is different, it's an OR condition.
      -- ---------------------------------------------------------------------------
      lp_na_qualifier_tbl(i).qualifier_grouping_no := i;
   END LOOP;


   -- ---------------------------------------------------------------
   -- Create/Re-Create offer in DRAFT status.
   -- ---------------------------------------------------------------
   IF (p_operation = 'CREATE') THEN
      Debug('Create offer in DRAFT status..............................');
   ELSE
      Debug('Re-create offer-related items.............................');
   END IF;

   ozf_offer_pub.process_modifiers(
      p_init_msg_list         => FND_API.g_false,
      p_api_version           => 1.0,
      p_commit                => FND_API.g_false,
      x_return_status         => x_return_status,
      x_msg_count             => x_msg_count,
      x_msg_data              => x_msg_data,
      p_offer_type            => 'NET_ACCRUAL',
      p_modifier_list_rec     => l_modifier_list_rec,
      p_modifier_line_tbl     => l_modifier_line_tbl,
      p_qualifier_tbl         => l_qualifier_tbl,
      p_budget_tbl            => lp_budget_tbl,
      p_act_product_tbl       => l_act_product_tbl,
      p_discount_tbl          => lp_discount_tbl,
      p_excl_tbl              => l_excl_tbl,
      p_offer_tier_tbl        => l_offer_tier_tbl,
      p_prod_tbl              => l_prod_tbl,
      p_na_qualifier_tbl      => lp_na_qualifier_tbl,
      x_qp_list_header_id     => l_qp_list_header_id,
      x_error_location        => x_error_location
   );


   IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;

   ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_qp_list_header_id := l_qp_list_header_id;

   -- ---------------------------------------------------------------
   -- Retrieve offer_id.
   -- ---------------------------------------------------------------
   FOR x IN (SELECT offer_id
             FROM   ozf_offers
             WHERE  qp_list_header_id = l_qp_list_header_id)
   LOOP
      x_offer_id := x.offer_id;

      -- ------------------------------------------------------------
      -- Update the benefit with this offer_id and set the benefit
      -- status to 'PENDING'
      -- ------------------------------------------------------------
      /*IF (p_operation = 'CREATE') THEN
         UPDATE pv_ge_benefits_b
         SET    additional_info_1   = x_offer_id,
                benefit_status_code = 'PENDING'
         WHERE  benefit_id          = p_benefit_id;

      ELSE
         UPDATE pv_ge_benefits_b
         SET    benefit_status_code = 'PENDING'
         WHERE  benefit_id          = p_benefit_id;
      END IF;
	  */
   END LOOP;

   --commit;

   -- ---------------------------------------------------------------
   -- Update offer to ACTIVE status.
   -- ---------------------------------------------------------------
   Debug('Update the offer to ACTIVE status..........................');
   l_modifier_list_rec                    := l_empty_modifier_list_rec;
   l_modifier_list_rec.QP_LIST_HEADER_ID  := l_qp_list_header_id;
   l_modifier_list_rec.offer_operation    := 'UPDATE';
   l_modifier_list_rec.modifier_operation := 'UPDATE';
   l_modifier_list_rec.status_code        := 'ACTIVE';
   l_modifier_list_rec.user_status_id     := 1604;     -- ACTIVE status

   Debug('l_modifier_list_rec.QP_LIST_HEADER_ID = ' ||
         l_modifier_list_rec.QP_LIST_HEADER_ID);

   ozf_offer_pub.process_modifiers(
      p_init_msg_list         => FND_API.g_false,
      p_api_version           => 1.0,
      p_commit                => FND_API.g_false,
      x_return_status         => x_return_status,
      x_msg_count             => x_msg_count,
      x_msg_data              => x_msg_data,
      p_offer_type            => 'NET_ACCRUAL',
      p_modifier_list_rec     => l_modifier_list_rec,
      p_modifier_line_tbl     => l_modifier_line_tbl,
      p_qualifier_tbl         => l_qualifier_tbl,
      p_budget_tbl            => l_budget_tbl,
      p_act_product_tbl       => l_act_product_tbl,
      p_discount_tbl          => l_discount_tbl,
      p_excl_tbl              => l_excl_tbl,
      p_offer_tier_tbl        => l_offer_tier_tbl,
      p_prod_tbl              => l_prod_tbl,
      p_na_qualifier_tbl      => l_na_qualifier_tbl,
      x_qp_list_header_id     => l_qp_list_header_id,
      x_error_location        => x_error_location
   );

   IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;

   ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;


   -------------------- Exception --------------------------
   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MSG_PUB.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                                    p_count     =>  x_msg_count,
                                    p_data      =>  x_msg_data);

      WHEN FND_API.g_exc_unexpected_error THEN
         x_return_status := FND_API.g_ret_sts_unexp_error;
         FND_MSG_PUB.count_and_get(
               p_encoded => FND_API.g_false,
               p_count   => x_msg_count,
               p_data    => x_msg_data
         );

      WHEN OTHERS THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
           FND_MSG_PUB.add_exc_msg(g_pkg_name, g_api_name);
        END IF;

        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.count_and_get(
              p_encoded => FND_API.g_false,
              p_count   => x_msg_count,
              p_data    => x_msg_data
        );

END create_offer;



--=============================================================================+
--|  Private Procedure                                                         |
--|                                                                            |
--|    Debug                                                                   |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES:                                                                     |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
PROCEDURE Debug(
   p_msg_string      IN VARCHAR2,
   p_msg_type        IN VARCHAR2 := 'PV_DEBUG_MESSAGE',
   p_token_type      IN VARCHAR2 := 'TEXT',
   p_statement_level IN NUMBER   := FND_LOG.LEVEL_PROCEDURE
)
IS
BEGIN
   IF (PV_DEBUG_LOW_ON) THEN
      FND_MESSAGE.Set_Name('PV', p_msg_type);
      FND_MESSAGE.Set_Token(p_token_type, p_msg_string);
      FND_MSG_PUB.Add;
   END IF;

   IF (p_statement_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(p_statement_level,
         'pv.plsql.' || g_pkg_name || '.' || g_api_name,
         p_msg_string
      );
   END IF;
END Debug;
-- =================================End of Debug================================


--=============================================================================+
--|  Public Procedure                                                          |
--|                                                                            |
--|    Set_Message                                                             |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES:                                                                     |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
PROCEDURE Set_Message(
    p_msg_name      IN      VARCHAR2,
    p_token1        IN      VARCHAR2 := NULL,
    p_token1_value  IN      VARCHAR2 := NULL,
    p_token2        IN      VARCHAR2 := NULL,
    p_token2_value  IN      VARCHAR2 := NULL,
    p_token3        IN      VARCHAR2 := NULL,
    p_token3_value  IN      VARCHAR2 := NULL,
    p_statement_level IN NUMBER   := FND_LOG.LEVEL_PROCEDURE
)
IS
BEGIN
   FND_MESSAGE.Set_Name('PV', p_msg_name);

   IF (p_token1 IS NOT NULL) THEN
      FND_MESSAGE.Set_Token(p_token1, p_token1_value);
   END IF;

   IF (p_token2 IS NOT NULL) THEN
      FND_MESSAGE.Set_Token(p_token2, p_token2_value);
   END IF;

   IF (p_token3 IS NOT NULL) THEN
      FND_MESSAGE.Set_Token(p_token3, p_token3_value);
   END IF;

   IF (p_statement_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(
         p_statement_level,
         'pv.plsql.' || g_pkg_name || '.' || g_api_name,
         FALSE
      );
   END IF;

   FND_MSG_PUB.Add;

END Set_Message;
-- ==============================End of Set_Message==============================


END PV_OFFER_PUB;

/
