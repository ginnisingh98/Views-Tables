--------------------------------------------------------
--  DDL for Package Body PV_MATCH_V2_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_MATCH_V2_PUB" as
/* $Header: pvxmtchb.pls 120.5 2005/12/15 14:25:34 amaram ship $*/

-- --------------------------------------------------------------
-- Used	for inserting output messages to the message table.
-- --------------------------------------------------------------
PROCEDURE Debug(
   p_msg_string	   IN VARCHAR2
);

PROCEDURE Set_Message(
    p_msg_level	    IN	    NUMBER,
    p_msg_name	    IN	    VARCHAR2,
    p_token1	    IN	    VARCHAR2,
    p_token1_value  IN	    VARCHAR2,
    p_token2	    IN	    VARCHAR2 :=	NULL,
    p_token2_value  IN	    VARCHAR2 :=	NULL,
    p_token3	    IN	    VARCHAR2 :=	NULL,
    p_token3_value  IN	    VARCHAR2 :=	NULL
);

-- %%%%%%%%%%%%%%%%%%%%%%  Private Routines %%%%%%%%%%%%%%%%%%%%%%%
-- =================================================================
-- get_no_of_delimiter will return the no of delimiters	in a given
-- string.
-- When	p_attr_value is	"abc+++def+++ghi" and the delimiter is
-- "+++" then the output from this function would be 2
-- which means there are two delimiters	in this	function
-- =================================================================

FUNCTION get_no_of_delimiter
(
     p_attr_value IN VARCHAR2,
     p_delimiter IN VARCHAR2
)
RETURN NUMBER;

PROCEDURE tokenize
(
   p_attr_value		IN  VARCHAR2,
   p_delimiter		IN  VARCHAR2,
   p_attr_value_tbl	OUT NOCOPY JTF_VARCHAR2_TABLE_4000
);

-- %%%%%%%%%%%%%%%%%%%%%%  End of Private Routines %%%%%%%%%%%%%%%%%%%%%%%

Procedure Manual_match(
    p_api_version_number    IN	   NUMBER,
    p_init_msg_list	    IN	   VARCHAR2 := FND_API.G_FALSE,
    p_commit		    IN	   VARCHAR2 := FND_API.G_FALSE,
    p_validation_level	    IN	   NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_attr_id_tbl	    IN OUT NOCOPY   JTF_NUMBER_TABLE,
    p_attr_value_tbl	    IN OUT NOCOPY   JTF_VARCHAR2_TABLE_4000,
    p_attr_operator_tbl	    IN OUT NOCOPY   JTF_VARCHAR2_TABLE_100,
    p_attr_data_type_tbl    IN OUT NOCOPY   JTF_VARCHAR2_TABLE_100,
    p_attr_selection_mode   IN	   VARCHAR2,
    p_att_delmter	    IN	   VARCHAR2,
    p_selection_criteria    IN	   VARCHAR2,
    p_resource_id	    IN	   NUMBER,
    p_lead_id		    IN	   NUMBER,
    p_auto_match_flag	    IN	   VARCHAR2,
    p_get_distance_flag	    IN	   VARCHAR2 := 'F',
    x_matched_id	    OUT    NOCOPY JTF_NUMBER_TABLE,
    x_partner_details	    OUT    NOCOPY JTF_VARCHAR2_TABLE_4000,
    x_distance_tbl	    OUT    NOCOPY JTF_NUMBER_TABLE,
    x_distance_uom_returned OUT    NOCOPY VARCHAR2,
    x_flagcount		    OUT    NOCOPY JTF_VARCHAR2_TABLE_100,
    x_return_status	    OUT    NOCOPY VARCHAR2,
    x_msg_count		    OUT    NOCOPY NUMBER,
    x_msg_data		    OUT    NOCOPY VARCHAR2,
    p_top_n_rows_by_profile IN     VARCHAR2 := 'T'
) IS

   l_api_name		 CONSTANT VARCHAR2(30) := 'Manual_Match';
   l_api_version_number	 CONSTANT NUMBER       := 1.0;


   cursor lc_get_incumbent_pt (pc_lead_id number) is
      select asla.INCUMBENT_PARTNER_PARTY_ID
      from as_leads_all	asla
      where asla.lead_id = pc_lead_id;


    l_matched_id		JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
    l_new_matched_id		JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();

    l_incumbent_pt_party_id	NUMBER;
    l_matched_tbl_last_idx	NUMBER := 0;
    l_incumbent_idx		NUMBER := 0;

    l_prefered_partner_distance NUMBER;

    l_distance_uom	   VARCHAR2(100);
    l_customer_address	   pv_locator.party_address_rec_type;
   --x_distance_uom_returned VARCHAR2(30);

   l_no_of_prefered_pts	   NUMBER := 0;
   l_prefered_pt_id_tbl	   JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_prefered_dist_tbl	   JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_prefered_dist_uom	   VARCHAR2(200);
   l_partner_dist_tbl	   JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_tokenize_attr_tbl	   JTF_VARCHAR2_TABLE_4000 := JTF_VARCHAR2_TABLE_4000();

   l_locator_flag	   VARCHAR2(1) := 'Y';
BEGIN

   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      debug('In '||l_api_name);
   END IF;

   IF NOT FND_API.Compatible_API_Call (l_api_version_number,
				       p_api_version_number,
				       l_api_name,
				       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   END IF;
    x_matched_id	:= JTF_NUMBER_TABLE();
    x_partner_details	:= JTF_VARCHAR2_TABLE_4000();
    x_distance_tbl	:= JTF_NUMBER_TABLE();
    x_flagcount		:= JTF_VARCHAR2_TABLE_100();

   -- Initialize message list if p_init_msg_list is set	to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      fnd_msg_pub.initialize;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS	;

   -- ================================================================================
   -- Get matched Partner ID's for the specified attributes
   -- ================================================================================

     Form_Where_clause(
	 p_api_version_number  => l_api_version_number
	,p_init_msg_list       => p_init_msg_list
	,p_commit	       => p_commit
	,p_validation_level    => FND_API.G_VALID_LEVEL_FULL
	,p_attr_id_tbl	       => p_attr_id_tbl
	,p_attr_value_tbl      => p_attr_value_tbl
	,p_attr_operator_tbl   => p_attr_operator_tbl
	,p_attr_data_type_tbl  => p_attr_data_type_tbl
	,p_attr_selection_mode => p_attr_selection_mode
	,p_att_delmter	       => p_att_delmter
	,p_selection_criteria   => p_selection_criteria
	,p_resource_id	       => p_resource_id
	,p_lead_id	       => p_lead_id
	,p_auto_match_flag     => p_auto_match_flag
        ,p_top_n_rows_by_profile => p_top_n_rows_by_profile
	,x_matched_id	       => x_matched_id
	,x_return_status       => x_return_status
	,x_msg_count	       => x_msg_count
	,x_msg_data	       => x_msg_data);


   -- ================================================================================
   -- Get Preferred Partner Details
   -- ================================================================================

      open lc_get_incumbent_pt (p_lead_id);
      fetch lc_get_incumbent_pt	into l_incumbent_pt_party_id;
      close lc_get_incumbent_pt;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         debug('Preferred partner for lead :'||p_lead_id||' is '||l_incumbent_pt_party_id);
      END IF;

      -- Checking to see if the preferred partner already exists in the matched partner tbl

      IF (x_matched_id.EXISTS(1) AND l_incumbent_pt_party_id IS NOT NULL) THEN
	FOR x IN (
	 SELECT idx
	 FROM   (SELECT rownum idx, column_value party_id
		 FROM  (SELECT column_value
			FROM TABLE (CAST(x_matched_id AS JTF_NUMBER_TABLE)))) a
	 WHERE  a.party_id = l_incumbent_pt_party_id)
	LOOP
	   l_incumbent_idx := x.idx;

	   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
	      debug('Preferred partner already exists at matched partner list, position is '||l_incumbent_idx);
	   END IF;


	END LOOP;
      END IF;

      -- Adding preferred partner to matched partner id tbl
      IF l_incumbent_idx = 0 and l_incumbent_pt_party_id IS NOT NULL THEN

         x_matched_id.extend;
	 x_matched_id(x_matched_id.count) := l_incumbent_pt_party_id;

      END IF;

      l_matched_id := x_matched_id;

   -- ------------------------------------------------------------------------
   -- Retrieve customer-to-partner distance info...
   --
   -- Execute Geo Proximity API	only when there	is at least one	partner
   -- returned from Partner Matching above.
   -- ------------------------------------------------------------------------
     IF (p_get_distance_flag = 'T' AND
        l_matched_id.EXISTS(1) AND l_matched_id.COUNT > 0)
     THEN
      -- -------------------------------------------------------------
      -- Retrieve location_id for this opportunity.
      -- -------------------------------------------------------------
         IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
	    Debug('before retrieving locator info');
	 END IF;
      BEGIN
	 SELECT	b.location_id
	 INTO	l_customer_address.location_id
	 FROM	as_leads_all   a,
		hz_party_sites b,
		hz_locations   l
	 WHERE	a.lead_id	= p_lead_id AND
		a.customer_id	= b.party_id AND
		b.party_site_id	= a.address_id AND
		b.location_id	= l.location_id	AND
		l.geometry IS NOT NULL;



	 EXCEPTION
	   WHEN	NO_DATA_FOUND THEN

		l_locator_flag := 'N';

      END;


     IF l_locator_flag = 'Y' THEN
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         Debug('Location ID: ' || l_customer_address.location_id);

         Debug('..........................................................');
         Debug('Calling pv_locator.Get_Partners..........................');
         Debug('# of Partners Sent: ' || l_matched_id.COUNT);

	 for i in 1 .. x_matched_id.count
	 loop
	     Debug('Partner Id ' || l_matched_id(i));
	 end loop;
      END IF;

      -- -------------------------------------------------------------
      -- Execute geo proximity API.
      -- -------------------------------------------------------------

      -- Default to mile?
      l_distance_uom :=	pv_locator.g_distance_unit_mile;
      pv_locator.Get_Partners (
	 p_api_version	    => 1.0,
	 p_init_msg_list    => FND_API.g_false,
	 p_commit           => FND_API.g_false,
	 p_validation_level => FND_API.g_valid_level_full,
	 p_customer_address => l_customer_address,
	 p_partner_tbl	    => l_matched_id,
	 p_max_no_partners  => null,
	 p_distance	    => null,
	 p_distance_unit    => l_distance_uom,
	 p_sort_by_distance => 'T',
	 x_partner_tbl	    => x_matched_id,
	 x_distance_tbl	    => x_distance_tbl,
	 x_distance_unit    => x_distance_uom_returned,
	 x_return_status    => x_return_status,
	 x_msg_count	    => x_msg_count,
	 x_msg_data	    => x_msg_data
      );

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
	 RAISE FND_API.G_EXC_ERROR;

      ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
	 RAISE FND_API.g_exc_unexpected_error;
      END IF;

      IF (x_distance_uom_returned = pv_locator.g_distance_unit_km) THEN
	 x_distance_uom_returned := 'KILOMETERS';

      ELSIF (x_distance_uom_returned = pv_locator.g_distance_unit_mile)	THEN
	 x_distance_uom_returned := 'MILES';
      END IF;

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       Debug('Distance UOM returned is: ' || x_distance_uom_returned);
       Debug('# of Partners Returned: ' || x_matched_id.COUNT);
    END IF;




   -- ------------------------------------------------------------------------
   -- Adding preferred partner on top
   -- ------------------------------------------------------------------------

   IF  l_incumbent_pt_party_id IS NOT NULL THEN

     FOR x IN (
	SELECT idx
	FROM   (SELECT rownum idx, column_value party_id
		 FROM  (SELECT column_value
			FROM TABLE (CAST(x_matched_id AS JTF_NUMBER_TABLE)))) a
	WHERE  a.party_id = l_incumbent_pt_party_id)
	LOOP
	 l_incumbent_idx := x.idx;
	END LOOP;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
           debug('location of Preferred partner in matched partner list '||l_incumbent_idx);
        END IF;

        l_prefered_partner_distance := x_distance_tbl(l_incumbent_idx);

      IF (x_matched_id.COUNT > 1) THEN
         FOR i IN REVERSE 1..(l_incumbent_idx - 1) LOOP
            x_matched_id(i + 1) := x_matched_id(i);
	    x_distance_tbl(i+1) := x_distance_tbl(i);

         END LOOP;

         x_matched_id(1)   := l_incumbent_pt_party_id;
	 x_distance_tbl(1) := l_prefered_partner_distance;
      END IF;


   END IF;

   -- ------------------------------------------------------------------------
   -- Getting the partner details
   -- ------------------------------------------------------------------------

   for i in 1 .. x_matched_id.count loop

     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
        debug('Partner ID after prefered partner on top '||x_matched_id(i));
        debug('Distance after prefered partner on top '||x_distance_tbl(i));
     END IF;
   end loop;
   END IF;

  END IF;
   IF x_matched_id.count > 0 THEN

      g_from_match_lov_flag := TRUE;

      Get_Matched_Partner_Details(
	  p_api_version_number	   => 1.0
	 ,p_init_msg_list	   => FND_API.G_FALSE
	 ,p_commit		   => FND_API.G_FALSE
	 ,p_validation_level	   => FND_API.G_VALID_LEVEL_FULL
	 ,p_lead_id		   => p_lead_id
	 ,p_extra_partner_details  => null
	 ,p_matched_id		   => x_matched_id
	 ,x_partner_details	   => x_partner_details
	 ,x_flagcount		   => x_flagcount
	 ,x_return_status	   => x_return_status
	 ,x_msg_count		   => x_msg_count
	 ,x_msg_data		   => x_msg_data);

	IF (x_return_status = fnd_api.g_ret_sts_error) THEN
	      RAISE fnd_api.g_exc_error;
	ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error)	THEN
	      RAISE fnd_api.g_exc_unexpected_error;
	END IF;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
	   Debug('# of Partners Returned from matched_partner_details: ' || x_matched_id.COUNT);
        END IF;

   END IF;



   IF FND_API.To_Boolean ( p_commit )	THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if	count is 1, get	message	info.
   fnd_msg_pub.Count_And_Get( p_encoded	  =>  FND_API.G_FALSE,
	    p_count	=>  x_msg_count,
	    p_data	=>  x_msg_data);

EXCEPTION

   WHEN	FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR ;

      fnd_msg_pub.Count_And_Get( p_encoded   =>	 FND_API.G_FALSE,
				 p_count     =>	 x_msg_count,
				 p_data	     =>	 x_msg_data);

   WHEN	FND_API.G_EXC_UNEXPECTED_ERROR THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      fnd_msg_pub.Count_And_Get( p_encoded   =>	 FND_API.G_FALSE,
				 p_count     =>	 x_msg_count,
				 p_data	     =>	 x_msg_data);


   WHEN	OTHERS THEN

      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


      fnd_msg_pub.Count_And_Get( p_encoded   =>	 FND_API.G_FALSE,
				 p_count     =>	 x_msg_count,
				 p_data	     =>	 x_msg_data);

END Manual_Match;

--=============================================================================+
--|  Procedure								       |
--|									       |
--|   Form_WHere_clause							       |
--|	   This	procedure Takes	attributes and their values and	forms where    |
--|	   condition to	search for partners. It	keeps on dropping attributes   |
--|	   in where condition until a partner is found or they get exhausted   |
--|									       |
--|  Parameters								       |
--|  IN									       |
--|  OUT								       |
--|									       |
--|									       |
--| NOTES								       |
--|									       |
--| HISTORY								       |
--|									       |
--==============================================================================

procedure Form_Where_Clause(
    p_api_version_number   IN	  NUMBER,
    p_init_msg_list	   IN	  VARCHAR2 := FND_API.G_FALSE,
    p_commit		   IN	  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level	   IN	  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_attr_id_tbl	   IN OUT NOCOPY   JTF_NUMBER_TABLE,
    p_attr_value_tbl	   IN OUT NOCOPY   JTF_VARCHAR2_TABLE_4000,
    p_attr_operator_tbl	   IN OUT NOCOPY   JTF_VARCHAR2_TABLE_100,
    p_attr_data_type_tbl   IN OUT NOCOPY   JTF_VARCHAR2_TABLE_100,
    p_attr_selection_mode  IN	  VARCHAR2,
    p_att_delmter	   IN	  VARCHAR2,
    p_selection_criteria   IN	  VARCHAR2,
    p_resource_id	   IN	  NUMBER,
    p_lead_id		   IN	  NUMBER,
    p_auto_match_flag	   IN	  VARCHAR2,
    x_matched_id	   OUT    NOCOPY   JTF_NUMBER_TABLE,
    x_return_status	   OUT    NOCOPY   VARCHAR2,
    x_msg_count		   OUT    NOCOPY   NUMBER,
    x_msg_data		   OUT    NOCOPY   VARCHAR2,
    p_top_n_rows_by_profile IN    VARCHAR2 := 'T')IS

   Type	l_tmp is Table of Varchar2(4000) index by binary_integer;

   l_tmp_tbl		      JTF_VARCHAR2_TABLE_4000 := JTF_VARCHAR2_TABLE_4000();
   l_tmp_tbl1		      l_tmp;
   l_attr_val_cnt_tbl	      JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_where		      Varchar2(32000);
   l_value_count	      Number :=	0;
   l_tmp_where		      Varchar2(32000);
   attr_seq		      NUMBER :=	1;
   l_attr_val_count	      NUmber;
   l_attr		      VARCHAR2(100);
   l_attr_value		      VARCHAR2(20000);
   l_prt_matched	      boolean := true;
   l_matched_attr_cnt	      number;
   l_rank_base_2	      number :=	1;
   tbl_cnt		      Number;
   cnt			      Number;
   l_category		      Varchar2(30);
   l_source_id		      Number;
   isCm			      boolean := false;
   isVad		      boolean := false;
   isAm			      boolean := false;
   l_cm_tmp		      varchar2(1);
   l_delm_cnt		      Number :=	0;
   l_delm_and_cnt	      Number :=	0;
   l_delm_or_cnt	      Number :=	0;
   l_attr_val_len	      Number :=	0;
   l_comma_cnt		      Number :=	1;
   l_attr_operator	      varchar2(100);
   l_delm_betwn_cnt	      Number :=	0;
   l_delm_length	      number :=	0;
   l_num_bet_point	      number :=	0;
   l_between_bef_val	      varchar2(10000);
   l_between_aft_val	      varchar2(10000);
   l_bet_bef_curr_val	      varchar2(10000);
   l_bet_aft_curr_val	      varchar2(10000);
   l_base_currency	      varchar2(10000);
   isDate		      boolean := false;
   l_date_num		      Number :=	0;
   j			      Number :=	0;
   l_attr_curr_value	      varchar2(10000);

   cursor lc_get_resource_details (pc_resource_id number) is
       select jtfre.category, jtfre.source_id
       from jtf_rs_resource_extns jtfre
       where jtfre.resource_id	= pc_resource_id;

   cursor lc_is_cm (pc_resource_id number, pc_lead_id number) is
      select 'X'
      from pv_party_notifications pvpn,	pv_lead_assignments pvla , pv_lead_workflows pvlw
      where pvlw.lead_id = pc_lead_id
      and   pvlw.entity	 = 'OPPORTUNITY'
      and   pvlw.LATEST_ROUTING_FLAG  =	'Y'
      and   pvlw.routing_status	= 'MATCHED'
      and   pvlw.wf_item_key = pvla.WF_ITEM_KEY
      and   pvlw.wf_item_type =	pvla.wf_item_type
      and   pvla.lead_assignment_id = pvpn.lead_assignment_id
      and   pvpn.resource_id = pc_resource_id
      and   pvpn.notification_type = 'MATCHED_TO';


   l_api_name		 CONSTANT VARCHAR2(30) := 'Form_Where_Clause';
   l_api_version_number	 CONSTANT NUMBER       := 1.0;

   -- pklin
   l_distance_uom	   VARCHAR2(30);
   l_customer_address	   pv_locator.party_address_rec_type;
   --x_distance_uom_returned VARCHAR2(30);

   l_matched_id		   JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_no_of_prefered_pts	   NUMBER := 0;
   l_prefered_pt_id_tbl	   JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_prefered_dist_tbl	   JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_prefered_dist_uom	   VARCHAR2(200);
   l_partner_dist_tbl	   JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_tokenize_attr_tbl	   JTF_VARCHAR2_TABLE_4000 := JTF_VARCHAR2_TABLE_4000();
   l_opr_meaning           VARCHAR2(30);

   -- --------------------------------------------------------------------------
   -- l_bind_var_tbl is used for keeping track of all bind variables as we go
   -- along in building the dynamic SQL for retrieving partners.
   -- --------------------------------------------------------------------------
   l_bind_var_tbl          bind_var_tbl;
   l_bind_count            INTEGER;
   l_bind_var		varchar2(2000);

begin

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'In	' || l_api_name);
      fnd_msg_pub.Add;
   END IF;

   -- Standard call to check for call compatibility.

   IF NOT FND_API.Compatible_API_Call (l_api_version_number,
				       p_api_version_number,
				       l_api_name,
				       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   END IF;

   -- Initialize message list if p_init_msg_list is set	to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      fnd_msg_pub.initialize;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS	;
   x_matched_id	:= JTF_NUMBER_TABLE();

   if p_attr_id_tbl.count()	   = 0
   or p_attr_value_tbl.count()	   = 0
   or p_attr_operator_tbl.count()  = 0
   or p_attr_data_type_tbl.count() = 0
   then

      fnd_message.SET_NAME  ('PV', 'PV_MISSING_SEARCH_CRITERIA');
      fnd_msg_pub.ADD;
      raise FND_API.G_EXC_ERROR;

   end if;

   IF p_lead_id is null and p_resource_id is null THEN
	isAm := true;
   ELSE

     /**	Get Resource Details for resource id being passed in to	the api	**/

    open lc_get_resource_details	(pc_resource_id	=> p_resource_id);
    fetch  lc_get_resource_details into l_category, l_source_id;
    close lc_get_resource_details;

    IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
       fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
       fnd_message.Set_Token('TEXT', 'Resource Category:	' || nvl(l_category, 'NULL') ||	 ' Source Id: '	||
				    nvl(to_char(l_source_id), 'NULL') || ' for resource_id: ' || p_resource_id);
       fnd_msg_pub.Add;
    END IF;

   /**	If category of resource	is PARTY.. skip	this.
    **	If EMPLOYEE,  validate if resoruce is working as a CM for this lead id
   **/
   if l_category is NULL then

      fnd_message.SET_NAME  ('PV', 'PV_RESOURCE_NOT_FOUND');
      fnd_message.SET_TOKEN ('P_RESOURCE_ID', p_resource_id);
      fnd_msg_pub.ADD;

      raise FND_API.G_EXC_ERROR;

   elsif l_category = 'EMPLOYEE' then
      open lc_is_cm (pc_resource_id => p_resource_id, pc_lead_id => p_lead_id);
      fetch  lc_is_cm  into l_cm_tmp;
      close lc_is_cm;

      if l_cm_tmp='X' then
	 isCm := true;
      else
	 isAm := true;
      end if;


   elsif l_category = 'PARTY' then
      isVad  :=	true;
   end if;
 END IF;

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      if isCm then
	 fnd_message.Set_Token('TEXT', 'User Is	CM');
      elsif isAm then
	 fnd_message.Set_Token('TEXT', 'User Is	AM');
      elsif isVad then
	 fnd_message.Set_Token('TEXT', 'User Is	Vad');
      end if;
      fnd_msg_pub.Add;
   END IF;

   -- Standard call to check for call compatibility.
   -- Form the select statement	to search for partners based on	received where Condition

   -- The search criteria to pick the partners is based	on the following assumptions

   -- If the attribute is of type date the attribute length should be 16
   --	 The attribute will of format YYYYMMDDHH24MISS


   IF  p_attr_selection_mode = g_and_attr_select
   AND p_selection_criteria  = g_drop_attr_match
   THEN

       fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
       fnd_message.Set_Token('TEXT', 'This Attribute Selection Mode :'||g_and_attr_select||'and Selection Criteria :'||g_drop_attr_match||' Combination is not supported');
       fnd_msg_pub.Add;

       raise FND_API.G_EXC_ERROR;
   END IF;

   IF p_attr_selection_mode NOT IN (g_and_attr_select, g_or_attr_select) THEN

       fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
       fnd_message.Set_Token('TEXT', 'Attribute Selection Mode is wrong. Please pass in the correct value ');
       fnd_msg_pub.Add;

      raise FND_API.G_EXC_ERROR;


   END IF;

   IF p_selection_criteria NOT IN (g_drop_attr_match, g_nodrop_attr_match) THEN

       fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
       fnd_message.Set_Token('TEXT', 'Selection Criteria is wrong . Please pass in the correct value ');
       fnd_msg_pub.Add;

      raise FND_API.G_EXC_ERROR;


   END IF;





   l_value_count := p_attr_id_tbl.count;
   l_base_currency := nvl(fnd_profile.value('PV_COMMON_CURRENCY'),'USD');

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'Base Currency is '||l_base_currency);
      fnd_msg_pub.Add;
   END IF;

   -- ======================================================================================
   -- ======================================================================================
   --                              BEGIN LOOP
   --
   -- Loop through the input PL/SQL tables to build the dynamic SQL for retrieving partners.
   -- ======================================================================================
   -- ======================================================================================
   l_bind_count := 0;

   FOR attr_no in 1..l_value_count LOOP
      IF p_attr_operator_tbl(attr_seq) IN ( g_null_opr
                                       , g_not_null_opr
                                       , g_not_equals_opr )
      THEN

         SELECT decode ( p_attr_operator_tbl(attr_seq) , g_null_opr, 'Is Null'
                                                       , g_not_null_opr, 'Is Not Null'
                                                       , g_not_equals_opr, 'Not Equals')
         INTO   l_opr_meaning
         FROM   DUAL;

         fnd_message.Set_Name('PV', 'PV_OPERATOR_NOT_SUPPORTED');
	      fnd_message.Set_Token('P_OPERATOR',l_opr_meaning );
	      fnd_msg_pub.Add;
	      raise FND_API.G_EXC_ERROR;
      END IF;


      -- -------------------------------------------------------------------------------
      -- Individual inner SQL statement. Each name-value pair constitutues one or more
      -- inner SQL statements.  Attributes that have multiple values (e.g. country =
      -- 'US', 'GB') will have multiple inner SQL statements, one for each OR condition.
      -- -------------------------------------------------------------------------------
      l_bind_count := l_bind_count + 1;

      l_tmp_where := 'select distinct t.party_id,' || l_rank_base_2 || ' rank ' ||
		     'from pv_search_attr_values t ' ||
		     'where t.attribute_id = :bv' || l_bind_count;

      l_bind_var_tbl(l_bind_count) := p_attr_id_tbl(attr_seq);


	IF  p_attr_data_type_tbl(attr_seq) =  g_currency_data_type THEN

	    l_attr_curr_value	 := p_attr_value_tbl(attr_seq);

	    l_attr_value := to_char(pv_check_match_pub.Currency_Conversion(
					   p_entity_attr_value	=> l_attr_curr_value,
					   p_rule_currency_code	=> l_base_currency));

       ELSE

	    l_attr_value    := p_attr_value_tbl(attr_seq);

       END IF;


	IF l_attr_value	IS NULL	THEN

	    fnd_message.Set_Name('PV', 'PV_BLANK_ATTR_TEXT');
	    fnd_message.Set_Token('P_ATTR_ID',p_attr_id_tbl(attr_seq) );
	    fnd_msg_pub.Add;
	    raise FND_API.G_EXC_ERROR;

	END IF;



       -- -------------------------------------------------------------------
       -- If there are more than one OR condition in the attribute value,
       -- break up the attribute value into individual values.
       -- -------------------------------------------------------------------
	l_delm_cnt	  := get_no_of_delimiter(p_attr_value_tbl(attr_no),p_att_delmter);

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
	   debug('Delimiter Count '||l_delm_cnt);
        END IF;

	l_delm_length	:= length(p_att_delmter);

	IF l_delm_cnt	> 0 THEN
   	   --  -------------------------------------------------------------------------
	   --  Attr Value will be broken down into individual elements in PL/SQL table
	   --  -------------------------------------------------------------------------
           tokenize
	   (
	      p_attr_value	=> l_attr_value,
	      p_delimiter	=> p_att_delmter,
	      p_attr_value_tbl	=> l_tokenize_attr_tbl
	   );
	 END IF;


       -- -------------------------------------------------------------------
       -- Forming the SQL Construct for	Operators for String Data Type
       -- -------------------------------------------------------------------
       IF p_attr_data_type_tbl(attr_seq) =  g_string_data_type THEN

	  l_tmp_where := l_tmp_where ||	' and upper(attr_text)	';

	  IF p_attr_operator_tbl(attr_seq) = g_equals_opr  THEN

	      IF  l_delm_cnt = 0
	      OR  (l_delm_cnt >	0 AND p_attr_selection_mode = g_and_attr_select
		   AND p_selection_criteria = g_nodrop_attr_match) THEN
		  l_attr_operator := 'like ';
	      ELSE
		 l_attr_operator := 'in	(';
	      END IF;

              IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
  	         debug('Operator '||l_attr_operator);
              END IF;

	  ELSIF	p_attr_operator_tbl(attr_seq) =	g_not_equals_opr THEN

	      IF  l_delm_cnt = 0
	      OR  (l_delm_cnt >	0 AND p_attr_selection_mode = g_and_attr_select
		  AND p_selection_criteria = g_nodrop_attr_match) THEN

		  l_attr_operator := 'not like ';
	      ELSE
		 l_attr_operator := 'not in (';
	      END IF;


	  ELSIF	p_attr_operator_tbl(attr_seq) =	g_null_opr THEN

		l_attr_operator	:= 'IS NULL';

	  ELSIF	p_attr_operator_tbl(attr_seq) =	g_not_null_opr THEN

		l_attr_operator	:= 'IS NOT NULL';

	  ELSE

		fnd_message.Set_Name('PV', 'PV_WRONG_OPR_FOR_STR');
		fnd_message.Set_Token('P_ATTR_OPR', p_attr_operator_tbl(attr_seq));
		fnd_msg_pub.Add;
		raise FND_API.G_EXC_ERROR;

	  END IF;

       -- -------------------------------------------------------------------
       -- Forming the SQL Construct for	Operators for Number and Date Data Type
       -- -------------------------------------------------------------------

       ELSE

	  IF l_delm_cnt	>= 0 THEN

	    IF p_attr_operator_tbl(attr_seq) = g_equals_opr THEN

	      IF  l_delm_cnt = 0 OR
	      (l_delm_cnt > 0 AND p_attr_selection_mode	= g_and_attr_select
	      AND p_selection_criteria =	g_nodrop_attr_match)  THEN
		 l_attr_operator := ' =	';
	      ELSE
		 l_attr_operator := 'in	(';
	      END IF;


	    ELSIF p_attr_operator_tbl(attr_seq)	= g_not_equals_opr THEN

	       IF  l_delm_cnt =	0 OR
	      (l_delm_cnt > 0 AND p_attr_selection_mode	= g_and_attr_select
	      AND p_selection_criteria =	g_nodrop_attr_match) THEN
		  l_attr_operator := ' <> ';
	       ELSE
		  l_attr_operator := 'not in (';
	       END IF;

	    END	IF;

	 END IF;


	  IF l_delm_cnt	= 0
	  OR ( p_selection_criteria = g_nodrop_attr_match AND l_delm_cnt > 0
	       AND p_attr_selection_mode = g_and_attr_select )
	  THEN

	     IF	p_attr_operator_tbl(attr_seq) =	g_greater_opr THEN

		l_attr_operator	:= ' > ';

	     ELSIF p_attr_operator_tbl(attr_seq) = g_less_opr THEN

		l_attr_operator	:= ' < ';

	     ELSIF p_attr_operator_tbl(attr_seq) = g_grt_or_equ_opr THEN

		l_attr_operator	:= ' >=	';

	     ELSIF p_attr_operator_tbl(attr_seq) = g_less_or_equ_opr THEN

		l_attr_operator	:= ' <=	';

	     END IF;

	  ELSIF	l_delm_cnt > 0 AND p_selection_criteria = g_drop_attr_match
	  AND	p_attr_operator_tbl(attr_seq) in ( g_greater_opr,
						    g_less_opr,
						    g_grt_or_equ_opr,
						    g_less_or_equ_opr )
	  THEN

	      fnd_message.Set_Name('PV', 'PV_WRONG_OPR_FOR_NUM_DATE');
	      fnd_message.Set_Token('P_ATTR_OPR', p_attr_operator_tbl(attr_seq));
	      fnd_msg_pub.Add;

	      raise FND_API.G_EXC_ERROR;

	  END IF;



	  IF p_attr_operator_tbl(attr_seq) = g_null_opr	THEN

	     l_attr_operator :=	'IS NULL';

	  ELSIF	p_attr_operator_tbl(attr_seq) =	g_not_null_opr	THEN

	     l_attr_operator :=	'IS NOT	NULL';


	  END IF;

	  IF  p_attr_data_type_tbl(attr_seq) in	(g_number_data_type, g_currency_data_type)
	  THEN
	      l_tmp_where := l_tmp_where || ' and attr_value ' ;
	  END IF;


	  IF p_attr_data_type_tbl(attr_seq) = g_date_data_type THEN
             l_tmp_where := l_tmp_where	|| ' and upper(attr_text) ';
	     l_date_num	     :=	to_number(l_attr_value);

	     IF	NOT to_number(l_attr_value) = l_date_num THEN
		   fnd_message.Set_Name('PV', 'PV_NOT_DATE_FORMAT');
		   fnd_msg_pub.Add;
		   raise FND_API.G_EXC_ERROR;
	     END IF;


	    IF	l_delm_cnt = 0 THEN
		IF length(l_attr_value)	> 16 THEN
		   fnd_message.Set_Name('PV', 'PV_NOT_DATE_VALUE');
		   fnd_msg_pub.Add;
         	   raise FND_API.G_EXC_ERROR;
		END IF;

	    ELSE
	       for i in	1 .. l_tokenize_attr_tbl.count
	       loop

		 IF length(l_tokenize_attr_tbl(i)) > 16
		 THEN
		    fnd_message.Set_Name('PV', 'PV_NOT_DATE_VALUE');
		    fnd_msg_pub.Add;
		    raise FND_API.G_EXC_ERROR;
		 END IF;
	      end loop;
	   END IF;

	END IF;

     END IF;


     l_attr_val_count := p_attr_id_tbl.count;

     -- =================================================================================
     -- =================================================================================
     -- Building WHERE Clause
     -- =================================================================================
     -- =================================================================================

     --	---------------------------------------------------------------------------------
     --	Forming	the Where Clause for BETWEEN Operator
     --	---------------------------------------------------------------------------------

     IF	(p_attr_operator_tbl(attr_seq) = g_between_opr) THEN
     Debug('##########################################################################');
     Debug('# Build where clause for BETWEEN operators');
     Debug('##########################################################################');
	 l_attr_val_cnt_tbl.extend;
	 l_attr_val_cnt_tbl(attr_no) :=	1;

	 l_rank_base_2	  := l_rank_base_2 * 2;


	 IF l_tokenize_attr_tbl.count >	2 THEN

		fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
		fnd_message.Set_Token('TEXT', 'Attr Value of this format is not	supported for BETWEEN Operator '||l_attr_value);
		fnd_msg_pub.Add;

		raise FND_API.G_EXC_ERROR;
	 END IF;



	  -- ----------------------------------------------------------------------------------
	  -- Populate l_between_bef_val and l_between_aft_val
	  -- ----------------------------------------------------------------------------------
	 for i in 1 ..	l_tokenize_attr_tbl.count
	 loop

	   IF p_attr_data_type_tbl(attr_seq) = g_currency_data_type THEN
	      l_between_bef_val	:=  to_char(pv_check_match_pub.Currency_Conversion(
					   p_entity_attr_value	=> l_tokenize_attr_tbl(i),
					   p_rule_currency_code	=> l_base_currency));

	      l_between_aft_val	:=  to_char(pv_check_match_pub.Currency_Conversion(
					   p_entity_attr_value	=> l_tokenize_attr_tbl(i+1),
					   p_rule_currency_code	=> l_base_currency));
	   ELSIF p_attr_data_type_tbl(attr_seq) = g_string_data_type OR p_attr_data_type_tbl(attr_seq) = g_date_data_type   THEN

	      l_between_bef_val	:= upper(l_tokenize_attr_tbl(i));
	      l_between_aft_val	:= upper(l_tokenize_attr_tbl(i+1));

	   ELSE

	      l_between_bef_val	:= l_tokenize_attr_tbl(i);
	      l_between_aft_val	:= l_tokenize_attr_tbl(i+1);

	   END IF;

	   EXIT	WHEN i+1 = 2;

	 end loop;


	  -- ----------------------------------------------------------------------------------
	  -- Insert bind variables for between operators.
	  -- ----------------------------------------------------------------------------------
	  IF p_attr_data_type_tbl(attr_seq) = g_string_data_type THEN
		fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
		fnd_message.Set_Token('TEXT', 'BETWEEN operator	is not supported for STRING data type');
		fnd_msg_pub.Add;

		raise FND_API.G_EXC_ERROR;

	  ELSE
	        l_bind_count := l_bind_count + 1;
		l_bind_var_tbl(l_bind_count) := l_between_bef_val;

		l_tmp_where  := l_tmp_where || ' BETWEEN :bv' || TO_CHAR(l_bind_count) ||
		                ' AND :bv' || TO_CHAR(l_bind_count + 1);

		-- ----------------------------------------------------------------------------
		-- Need to increment l_bind_count here because BETWEEN takes 2 bind variables.
		-- ----------------------------------------------------------------------------
                l_bind_count := l_bind_count + 1;
		l_bind_var_tbl(l_bind_count) := l_between_aft_val;
	  END IF;

     --	-------------------------------------------------------------------
     --	Forming	the Where Clause where there is	no delimiter in	Attr Value
     --	-------------------------------------------------------------------


     ELSIF l_delm_cnt =	0 then
     Debug('##########################################################################');
     Debug('# Build where clause for attributes with single value');
     Debug('##########################################################################');

	l_attr_val_cnt_tbl.extend;
	l_attr_val_cnt_tbl(l_attr_val_cnt_tbl.count) :=	1;

	IF p_selection_criteria = g_drop_attr_match THEN

	   l_rank_base_2 := l_rank_base_2 * 2;

	END IF;

	IF (p_attr_operator_tbl(attr_seq) = g_not_null_opr OR
	   p_attr_operator_tbl(attr_seq) = g_null_opr)
	THEN
	   l_tmp_where := l_tmp_where || l_attr_operator;

	ELSE
	   l_bind_count                 := l_bind_count + 1;
           l_bind_var_tbl(l_bind_count) := UPPER(l_attr_value);

	   l_tmp_where := l_tmp_where || l_attr_operator || ' :bv' || l_bind_count || ' ';

	END IF;

     --	-------------------------------------------------------------------
     --	Forming	the Where Clause where there is	delimiter in Attr Value
     --	and for	ANY CONDITION (	it can be DROPPING of attributes as well
     --	as for NO Drop )
     --	-------------------------------------------------------------------


     ELSIF l_delm_cnt >	0  AND	 p_attr_selection_mode = g_or_attr_select THEN
     Debug('##########################################################################');
     Debug('# Build where clause for multiple values and p_attr_selection_mode = OR');
     Debug('##########################################################################');

	IF p_selection_criteria = g_drop_attr_match THEN
          Debug('##########################################################################');
          Debug('# for p_selection_criteria = g_drop_attr_match');
          Debug('##########################################################################');

	      l_rank_base_2 := l_rank_base_2 * 2;

	END IF;

	l_attr_val_len := length(l_attr_value);
	l_tmp_where    := l_tmp_where || l_attr_operator;

	l_delm_or_cnt  := l_delm_cnt;


	 FOR k in 1..l_tokenize_attr_tbl.count LOOP
	    IF l_delm_or_cnt > 0 THEN
	       l_bind_count := l_bind_count + 1;
               l_tmp_where := l_tmp_where || ':bv' || l_bind_count || ',';
	       l_bind_var_tbl(l_bind_count) := UPPER(l_tokenize_attr_tbl(k));

	       l_delm_or_cnt :=	l_delm_or_cnt -	1;

	    ELSIF  ( l_delm_or_cnt = 0 AND  k =	l_tokenize_attr_tbl.COUNT ) THEN
	       l_bind_count := l_bind_count + 1;
               l_tmp_where := l_tmp_where || ':bv' || l_bind_count || ')';
	       l_bind_var_tbl(l_bind_count) := UPPER(l_tokenize_attr_tbl(k));

	    END	IF;
	END LOOP;

	l_attr_val_cnt_tbl.extend;
	l_attr_val_cnt_tbl(l_attr_val_cnt_tbl.count) :=	1;

     --	-------------------------------------------------------------------
     --	Forming	the Where Clause where there is	delimiter in Attr Value
     --	and for	ALL and	OR Condition. Not supported for	ALL and	AND condition
     --	-------------------------------------------------------------------

     ELSIF l_delm_cnt >	0 AND	p_selection_criteria = g_nodrop_attr_match
     AND p_attr_selection_mode = g_and_attr_select THEN
     Debug('##########################################################################');
     Debug('# Build where clause for multiple values and p_attr_selection_mode = AND');
     Debug('##########################################################################');

	 l_delm_and_cnt	:= l_delm_cnt;

	 FOR i IN 1 .. l_tokenize_attr_tbl.count
	 LOOP

	    IF p_attr_data_type_tbl(attr_seq) in (g_number_data_type, g_currency_data_type) THEN
	      -- ------------------------------------------------------------------------------
	      -- Do not increment l_bind_count in when the operator is BETWEEN because
	      -- the previous l_tmp_where is overwritten by this select statement here.
	      -- ------------------------------------------------------------------------------
	      IF (i > 1) THEN
                 l_bind_count := l_bind_count + 1;
              END IF;

              l_bind_var_tbl(l_bind_count) := p_attr_id_tbl(attr_seq);

	      l_tmp_where := 'select distinct t.party_id,' || l_rank_base_2 ||	' rank ' ||
			     'from pv_search_attr_values t ' ||
			     'where t.attribute_id = :bv' || l_bind_count || '	and attr_value ';

	    ELSE
	      -- ------------------------------------------------------------------------------
	      -- Do not increment l_bind_count in when the operator is BETWEEN because
	      -- the previous l_tmp_where is overwritten by this select statement here.
	      -- ------------------------------------------------------------------------------
	      IF (i > 1) THEN
                 l_bind_count := l_bind_count + 1;
              END IF;

	      l_bind_var_tbl(l_bind_count) := p_attr_id_tbl(attr_seq);

	       l_tmp_where := 'select distinct t.party_id,' || l_rank_base_2 ||	' rank ' ||
			      'from pv_search_attr_values t ' ||
			      'where t.attribute_id = :bv' || l_bind_count || '	and uppeR(attr_text) ';

	    END	IF;

	    IF l_delm_and_cnt >	0 THEN

	       IF p_attr_data_type_tbl(attr_seq) in (g_number_data_type, g_currency_data_type) THEN
	          l_bind_count := l_bind_count + 1;
		  l_bind_var_tbl(l_bind_count) := l_tokenize_attr_tbl(i);

		  l_tmp_where := l_tmp_where ||	l_attr_operator	|| ' :bv' || l_bind_count;

	       ELSE
	          l_bind_count := l_bind_count + 1;
		  l_bind_var_tbl(l_bind_count) := UPPER(l_tokenize_attr_tbl(i));

		  l_tmp_where := l_tmp_where ||	l_attr_operator	|| ' :bv' || l_bind_count;

		  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
		     debug('Temp Where '||l_tmp_where);
                  END IF;

	       END IF;

	       l_tmp_tbl.extend;
	       l_tmp_tbl(l_tmp_tbl.count) := l_tmp_where;
	       l_delm_and_cnt := l_delm_and_cnt	- 1;

	   ELSIF  ( l_delm_and_cnt = 0 and i = l_tokenize_attr_tbl.COUNT ) THEN
	          l_bind_count := l_bind_count + 1;
		  l_bind_var_tbl(l_bind_count) := UPPER(l_tokenize_attr_tbl(i));

		  l_tmp_where := l_tmp_where ||	l_attr_operator	|| ' :bv' || l_bind_count;

	    END	IF;
	END LOOP;

	l_attr_val_cnt_tbl.extend;
	l_attr_val_cnt_tbl(l_attr_val_cnt_tbl.count) :=	1;
    END	IF;

    IF l_value_count > 1 THEN

       attr_seq	:= attr_seq+1;

    END	IF;

    IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
       fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
       fnd_message.Set_Token('TEXT', 'l_tmp_where: ' ||	l_tmp_where);
       fnd_msg_pub.Add;
    END	IF;


    l_tmp_tbl.extend;
    l_tmp_tbl(l_tmp_tbl.count) := l_tmp_where;


   end loop;

   -- ======================================================================================
   -- ======================================================================================
   --                                END LOOP
   --
   -- End of building the inner portion (based on attribute name-value pair) of the dynamic
   -- SQL.
   -- ======================================================================================
   -- ======================================================================================



   -- -------------------------------------------------------------------------------
   -- Forming outer SELECT statement with no_merge hint.
   -- -------------------------------------------------------------------------------
   l_where := 'select /*+ no_merge(t) */  distinct t.party_id, rank from ( select party_id, sum(rank) rank from	( ';

   -- -------------------------------------------------------------------------------
   -- Concatenating indiviaul SQL's into a big SQL with UNION ALL.
   -- -------------------------------------------------------------------------------
   for k in 1..l_tmp_tbl.count() loop

      l_where := l_where || l_tmp_tbl(k);

      if k <> l_tmp_tbl.count()	then

	 l_where := l_where || ' union all ';

      end if;

   end loop;


   -- -------------------------------------------------------------------------------
   -- Forming group by statement for the inner SQL.
   -- -------------------------------------------------------------------------------
   IF p_selection_criteria = g_drop_attr_match THEN

      l_where := l_where || ') group by	party_id having	mod(sum(rank),2) <> 0 )	t, pv_partner_profiles pvpp ';

   ELSIF p_selection_criteria = g_nodrop_attr_match THEN

      l_where := l_where || ') group by	party_id ) t, pv_partner_profiles pvpp ';

   END IF;


   -- -------------------------------------------------------------------------------
   -- Forming predicates for the outer SQL.
   --
   -- Usage of SALES_PARTNER_FLAG has been obsoleted since 11.5.10
   -- -------------------------------------------------------------------------------
   if (isAm) then

      l_where := l_where  || ' , hz_parties PARTNER '
			  || ' where t.party_id = pvpp.partner_id '
                          || ' and   pvpp.partner_party_id = PARTNER.party_id '
                          || ' and   pvpp.status = ''A'' ';



      if p_auto_match_flag = 'Y' then

	 l_where := l_where  ||	' and pvpp.auto_match_allowed_flag = ''Y'' ';

      end if;

   elsif (isCm)	 then

      l_bind_count := l_bind_count + 1;
      l_bind_var_tbl(l_bind_count) := p_resource_id;

      l_where := l_where || ' , hz_parties partner '
			  || ' where t.party_id = pvpp.partner_id '
                          || ' and   pvpp.partner_party_id = PARTNER.party_id '
                          || ' and   pvpp.status = ''A'' '
			  || ' and  pvpp.partner_party_id in ( select  a.customer_id from as_accesses_all a '
			  || ' where  a.salesforce_id = :bv' || l_bind_count
			  || ' and  a.sales_lead_id is null and	 a.lead_id is null) ';

   elsif  (isVad) then

      l_bind_count := l_bind_count + 1;
      l_bind_var_tbl(l_bind_count) := l_source_id;

      l_where :=  l_where  || '	,hz_relationships INDIRECT_TO_VAD, hz_relationships INDIRECT_TO_VENDOR,	'
			   || '	hz_relationships CONTACT_TO_VAD, hz_organization_profiles HZOP,	hz_parties PARTNER '
			   || '	where  CONTACT_TO_VAD.party_id = :bv' || l_bind_count
			   || '	and  CONTACT_TO_VAD.object_id =	INDIRECT_TO_VAD.object_id '
			   || '	and  CONTACT_TO_VAD.directional_flag = ''F'' '
			   || '	and  CONTACT_TO_VAD.subject_table_name = ''HZ_PARTIES''	'
			   || '	and  CONTACT_TO_VAD.object_table_name =	''HZ_PARTIES'' '
			   || '	and  CONTACT_TO_VAD.status = ''A'''
			   || '	and  CONTACT_TO_VAD.start_date <= sysdate '
			   || '	and  nvl(CONTACT_TO_VAD.end_date,sysdate) >= sysdate '
			   || '	and  INDIRECT_TO_VAD.relationship_type = ''PARTNER_MANAGED_CUSTOMER'' '
			   || '	and  INDIRECT_TO_VAD.subject_table_name	= ''HZ_PARTIES'' '
			   || '	and  INDIRECT_TO_VAD.object_table_name = ''HZ_PARTIES''	'
			   || '	and  INDIRECT_TO_VAD.subject_id	= INDIRECT_TO_VENDOR.subject_id	'
			   || '	and  INDIRECT_TO_VAD.status = ''A'''
			   || '	and  INDIRECT_TO_VAD.start_date	<= sysdate '
			   || '	and  nvl(INDIRECT_TO_VAD.end_date,sysdate) >= sysdate '
			   || '	and  INDIRECT_TO_VENDOR.relationship_type =''PARTNER'' '
			   || '	and  INDIRECT_TO_VENDOR.subject_table_name = ''HZ_PARTIES'' '
			   || '	and  INDIRECT_TO_VENDOR.object_table_name = ''HZ_PARTIES'' '
			   || '	and  INDIRECT_TO_VENDOR.object_id   = HZOP.party_id '
			   || '	and  INDIRECT_TO_VENDOR.status = ''A'''
			   || '	and  INDIRECT_TO_VENDOR.start_date <= sysdate '
			   || '	and  nvl(INDIRECT_TO_VENDOR.end_date,sysdate) >= sysdate '
			   || '	and  INDIRECT_TO_VENDOR.subject_id = pvpp.partner_party_id '
			   || '	and  PARTNER.status = ''A'''
			   || '	and  HZOP.internal_flag	  = ''Y'' '
			   || '	and  HZOP.effective_end_date is	null '
			   || '	and  INDIRECT_TO_VENDOR.party_id  = pvpp.partner_id '
			   || '	and  pvpp.INDIRECTLY_MANAGED_FLAG   = ''Y'' '
			   || '	and  t.party_id	= pvpp.partner_id ';

      if p_auto_match_flag = 'Y' then
	 l_where := l_where  ||	' and pvpp.auto_match_allowed_flag = ''Y'' ';
      end if;

   end if;

   l_where := l_where || ' order by 2 desc ';

   if (l_tmp_tbl.count() > 0) then

      -- Match partners	for this where condition

      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
	 fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
	 fnd_message.Set_Token('TEXT', 'l_where	clause:	');
	 fnd_msg_pub.Add;
      END IF;

      for i in 1..ceil((length(l_where)/100)) loop
	 IF fnd_msg_pub.Check_Msg_Level	(fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
	    fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
	    fnd_message.Set_Token('TEXT', substr(l_where, (i-1)*100+1, 100));
	    fnd_msg_pub.Add;
	 END IF;
      end loop;


      -- ----------------------------------------------------------------------------------
      -- Print out the list of bind variables.
      -- ----------------------------------------------------------------------------------
      Debug('***************************************************************************');
      Debug('Bind Variables.............................................................');
      For j IN 1..l_bind_var_tbl.COUNT LOOP
           --since fnd_msg_pub supports debiug message of length 1972
	 -- we are passing split of attribute value as it may exceed 2000 length

	      l_bind_var := l_bind_var_tbl(j);
	      while (l_bind_var is not null) loop
		debug('l_bind_var_tbl(' || j || ') = ' ||substr( l_bind_var, 1, 1800 ));
		l_bind_var := substr( l_bind_var, 1801 );
	      end loop;
      END LOOP;
      Debug('***************************************************************************');



      Match_partner(
	  p_api_version_number  => 1.0
	 ,p_init_msg_list      => FND_API.G_FALSE
	 ,p_commit	       => FND_API.G_FALSE
	 ,p_validation_level   => FND_API.G_VALID_LEVEL_FULL
	 ,p_sql		       => l_where
	 ,p_selection_criteria  => p_selection_criteria
	 ,p_num_of_attrs       => l_tmp_tbl.count
         ,p_bind_var_tbl       => l_bind_var_tbl
         ,p_top_n_rows_by_profile => p_top_n_rows_by_profile
	 ,x_matched_prt	       => x_matched_id
	 ,x_prt_matched	       => l_prt_matched
	 ,x_matched_attr_cnt   => l_matched_attr_cnt
	 ,x_return_status      => x_return_status
	 ,x_msg_count	       => x_msg_count
	 ,x_msg_data	       => x_msg_data);

      IF (x_return_status = fnd_api.g_ret_sts_error) THEN
	 RAISE fnd_api.g_exc_error;
      ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error) THEN
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

   end if;

   -- This section is needed to	send matched attributes	to Client.


   cnt := 0;
   for i in l_matched_attr_cnt+1..l_attr_val_cnt_tbl.count
   loop
      cnt := cnt + l_attr_val_cnt_tbl(i) ;
   end loop;


   p_attr_id_tbl.trim(cnt);
   p_attr_value_tbl.trim(cnt);
   p_attr_operator_tbl.trim(cnt);
   p_attr_data_type_tbl.trim(cnt);


   IF FND_API.To_Boolean ( p_commit )	THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if	count is 1, get	message	info.
   fnd_msg_pub.Count_And_Get( p_encoded	  =>  FND_API.G_FALSE,
	    p_count	=>  x_msg_count,
	    p_data	=>  x_msg_data);

EXCEPTION

   WHEN	FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR ;

      fnd_msg_pub.Count_And_Get( p_encoded   =>	 FND_API.G_FALSE,
				 p_count     =>	 x_msg_count,
				 p_data	     =>	 x_msg_data);

   WHEN	FND_API.G_EXC_UNEXPECTED_ERROR THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      fnd_msg_pub.Count_And_Get( p_encoded   =>	 FND_API.G_FALSE,
				 p_count     =>	 x_msg_count,
				 p_data	     =>	 x_msg_data);


   WHEN	OTHERS THEN

      IF SQLCODE = -06502 THEN

	  fnd_message.Set_Name('PV', 'PV_NOT_DATE_FORMAT');
	  fnd_msg_pub.Add;

      ELSE

	  FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);

      END IF;


      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


      fnd_msg_pub.Count_And_Get( p_encoded   =>	 FND_API.G_FALSE,
				 p_count     =>	 x_msg_count,
				 p_data	     =>	 x_msg_data);

END Form_Where_Clause;



-- ----------------------------------------------------------------------------------
-- Procedure Match_Partner
-- ----------------------------------------------------------------------------------
Procedure Match_partner(
	 p_api_version_number	IN  NUMBER,
	 p_init_msg_list	IN  VARCHAR2 := FND_API.G_FALSE,
	 p_commit		IN  VARCHAR2 := FND_API.G_FALSE,
	 p_validation_level	IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
	 p_sql			IN  VARCHAR2,
	 p_selection_criteria	IN  VARCHAR2,
	 p_num_of_attrs		IN  NUMBER,
         p_bind_var_tbl         IN  bind_var_tbl,
	 p_top_n_rows_by_profile IN VARCHAR2 := 'T',
	 x_matched_prt		OUT NOCOPY JTF_NUMBER_TABLE,
	 x_prt_matched		OUT NOCOPY BOOLEAN,
	 x_matched_attr_cnt	OUT NOCOPY NUMBER,
	 x_return_status	OUT NOCOPY VARCHAR2,
	 x_msg_count		OUT NOCOPY NUMBER,
	 x_msg_data		OUT NOCOPY VARCHAR2
) IS

   l_possible_match_party_tbl JTF_VARCHAR2_TABLE_100 :=	JTF_VARCHAR2_TABLE_100();
   l_possible_match_rank_tbl  JTF_VARCHAR2_TABLE_100 :=	JTF_VARCHAR2_TABLE_100();
   l_possible_match_count     number :=	0;
   l_possible_rank_high	      number :=	0;
   l_match_count	      number :=	0;
   l_top_n_rows		      number;
   l_rank_base_2	      number;
   l_matching_rank	      number;
   l_combined_rank	      number;
   l_tmp_true_rank	      number;
   l_tmp_matching_rank	      number;
   l_tmp_combined_rank	      number;
   l_attr_count		      number;
   partner_id		      number;
   l_all_ranks		      varchar2(1000);

   l_api_name		 CONSTANT VARCHAR2(30) := 'Match_partner';
   l_api_version_number	 CONSTANT NUMBER       := 1.0;

   -- ------------------------------------------------------------------------------
   -- Variables for processing dynamic SQL.
   -- ------------------------------------------------------------------------------
   l_theCursor        INTEGER;
   l_column_party_id  NUMBER DEFAULT NULL;
   l_column_rank      NUMBER DEFAULT NULL;
   l_status           INTEGER;


begin
   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'In	' || l_api_name);
      fnd_msg_pub.Add;
   END IF;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version_number,
				       p_api_version_number,
				       l_api_name,
				       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   END IF;

   -- Initialize message list if p_init_msg_list is set	to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      fnd_msg_pub.initialize;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS	;
   x_matched_prt := JTF_NUMBER_TABLE();

   -- ------------------------------------------------------------------------
   -- Determines how many partners should be retrieved. This is determined
   -- by the profile PV_TOP_N_MATCH_PARTNERS. p_top_n_rows_by_profile
   -- determines whether we should get this value from the profile or just
   -- set it to a very large number.
   -- ------------------------------------------------------------------------
   -- ------------------------------------------------------------------------
   --IF (p_top_n_rows_by_profile = 'F') THEN
   --   l_top_n_rows := 1000000;

   --ELSE
   --   l_top_n_rows :=nvl(fnd_profile.value('PV_TOP_N_MATCH_PARTNERS'), 1000);
   --END IF;
   -- ------------------------------------------------------------------------

   --IN R12, Obsoleting profile option. PV_TOP_N_MATCH_PARTNERS
   --there is no longer a need to restrict the number of partners returned by the API. Remove the logic involved this profile option.

   l_top_n_rows := 1000000;


   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      debug('no of partner to be retrieved '||l_top_n_rows);
   END IF;

   l_matching_rank := 1;
   l_combined_rank := 1;
   l_all_ranks	   := '	1 ';


   IF p_selection_criteria = g_drop_attr_match THEN

      for i in 1..p_num_of_attrs - 1 loop

	   l_matching_rank := l_matching_rank *	2;
	   l_combined_rank := l_combined_rank +	l_matching_rank;
	   l_all_ranks	   := l_all_ranks || ' ' || l_combined_rank || ' '; -- like ' 1	3 8 15 31...etc'

      end loop;

      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
	 fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
	 fnd_message.Set_Token('TEXT', 'All ranks: ' ||	l_all_ranks);
	 fnd_msg_pub.Add;
      END IF;

   ELSIF p_selection_criteria = g_nodrop_attr_match THEN

      l_matching_rank := p_num_of_attrs;
      l_combined_rank := l_matching_rank;


      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
	 fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
	 fnd_message.Set_Token('TEXT', 'All ranks: ' ||	p_num_of_attrs);
	 fnd_msg_pub.Add;
      END IF;

      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
	 fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
	 fnd_message.Set_Token('TEXT', 'Combined rank must match: ' || l_combined_rank);
	 fnd_msg_pub.Add;
      END IF;


  END IF;


   -- ==============================================================================
   -- ==============================================================================
   -- Process the dynamic SQL to retrieve matching partner.
   -- ==============================================================================
   -- ==============================================================================
   l_theCursor := DBMS_SQL.OPEN_CURSOR;

   DBMS_SQL.PARSE(c             => l_theCursor,
                  statement     => p_sql,
                  language_flag => DBMS_SQL.NATIVE);

   -- -------------------------------------------------------------------------------
   -- Bind the bind variables.
   -- -------------------------------------------------------------------------------
   FOR i IN 1..p_bind_var_tbl.COUNT LOOP
      DBMS_SQL.BIND_VARIABLE(l_theCursor, ':bv' || i, p_bind_var_tbl(i));
   END LOOP;

   -- -------------------------------------------------------------------------------
   -- Define output columns
   -- -------------------------------------------------------------------------------
   DBMS_SQL.DEFINE_COLUMN(c          => l_theCursor,
                          position   => 1,
                          column     => l_column_party_id);

   DBMS_SQL.DEFINE_COLUMN(c          => l_theCursor,
                          position   => 2,
                          column     => l_column_rank);

   -- -------------------------------------------------------------------------------
   -- Execute the dynamic SQL
   -- -------------------------------------------------------------------------------
   l_status := DBMS_SQL.EXECUTE(l_theCursor);


   -- -------------------------------------------------------------------------------
   -- Process SQL output row by row
   -- -------------------------------------------------------------------------------
   WHILE (DBMS_SQL.FETCH_ROWS(c => l_theCursor) > 0) LOOP
      DBMS_SQL.COLUMN_VALUE(c         => l_theCursor,
                            position  => 1,
                            value     => partner_id);

      DBMS_SQL.COLUMN_VALUE(c         => l_theCursor,
                            position  => 2,
                            value     => l_rank_base_2);


      EXIT WHEN x_matched_prt.count = l_top_n_rows;

      IF p_selection_criteria = g_nodrop_attr_match THEN


      if l_combined_rank = l_rank_base_2 then

	 if l_match_count < l_top_n_rows then

	    IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
	       fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
	       fnd_message.Set_Token('TEXT', 'Rank matches.  Adding partner_id ' || partner_id);
	       fnd_msg_pub.Add;
	       fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
	       fnd_message.Set_Token('TEXT', 'Current rank: ' || l_rank_base_2 || ' for	partner_id: ' || partner_id);
	       fnd_msg_pub.Add;
	    END	IF;

	    l_match_count := l_match_count + 1;
	    x_matched_prt.extend;
	    x_matched_prt(l_match_count) := partner_id;


	 end if;

      else
	 if l_match_count > 0 then
	    IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
	       fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
	       fnd_message.Set_Token('TEXT', 'Did not find any more matching partner.  Exiting loop');
	       fnd_msg_pub.Add;
	    END	IF;
	    exit;
	 end if;
      end if;

     ELSIF p_selection_criteria = g_drop_attr_match THEN


      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
	 fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
	 fnd_message.Set_Token('TEXT', 'Combined rank must match: ' || l_combined_rank);
	 fnd_msg_pub.Add;
	 fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
	 fnd_message.Set_Token('TEXT', 'Current	rank: '	|| l_rank_base_2 || ' for partner_id: '	|| partner_id);
	 fnd_msg_pub.Add;
      END IF;

      while (mod (l_rank_base_2, 2) <> 0	  /* ignore even numbers which will never match	*/
	  and l_combined_rank >	l_rank_base_2	  /* stop when combined	rank drops below current rank */
	  and l_match_count = 0)		  /* only decrease combined rank if no partners	matched	*/
      loop

	 if instr(l_all_ranks, ' ' || l_rank_base_2 || ' ') = 0	then

	    -- not a complete match. eg. 'matches rank 1, 2, 4,	16. (missing 8). adds up to 23.
	    -- true rank is 7. that is,	sum of consecutive ranks
	    -- will always match at least rank 1 if odd	number rank. so	find out the true rank

	    l_tmp_combined_rank	:= l_combined_rank;
	    l_tmp_matching_rank	:= l_matching_rank;
	    l_tmp_true_rank	:= l_rank_base_2;

	    while l_tmp_combined_rank <> l_tmp_true_rank
	    loop

	       if l_tmp_combined_rank >	l_tmp_true_rank	then

		  l_tmp_combined_rank := l_tmp_combined_rank - l_tmp_matching_rank;

	       end if;

	       if l_tmp_true_rank > l_tmp_combined_rank	then

		  l_tmp_true_rank := l_tmp_true_rank - l_tmp_matching_rank;

	       end if;

	       l_tmp_matching_rank := l_tmp_matching_rank / 2;

	    end	loop;

	    IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
	       fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
	       fnd_message.Set_Token('TEXT', 'Found one	guaranteed match for partner: '	|| partner_id ||
					     ' at rank:	' || l_tmp_true_rank);
	       fnd_msg_pub.Add;
	    END	IF;

	    if l_tmp_true_rank > l_possible_rank_high then
	       l_possible_rank_high := l_tmp_true_rank;
	    end	if;

	    l_possible_match_count := l_possible_match_count + 1;
	    l_possible_match_party_tbl.extend();
	    l_possible_match_rank_tbl.extend();

	    l_possible_match_party_tbl(l_possible_match_count) := partner_id;
	    l_possible_match_rank_tbl(l_possible_match_count)  := l_tmp_true_rank;

	    exit;

	 else

	    l_combined_rank := l_combined_rank - l_matching_rank;
	    l_matching_rank := l_matching_rank / 2;

	    IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
	       fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
	       fnd_message.Set_Token('TEXT', 'Decreasing rank to ' || l_combined_rank);
	       fnd_msg_pub.Add;
	    END	IF;

	 end if;

	 for i in 1..l_possible_match_count loop

	    if l_combined_rank = l_possible_match_rank_tbl(i) then

	       if l_match_count	< l_top_n_rows then

		  l_match_count	:= l_match_count + 1;
		  x_matched_prt.extend;
		  x_matched_prt(l_match_count) := l_possible_match_party_tbl(i);

		  IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
		     fnd_message.Set_Name('PV',	'PV_DEBUG_MESSAGE');
		     fnd_message.Set_Token('TEXT', 'Adding possible matches. Partner_id	' || l_possible_match_party_tbl(i) ||
				       ' at ' || l_possible_match_rank_tbl(i));
		     fnd_msg_pub.Add;
		  END IF;

		  l_possible_match_rank_tbl(i) := 0; --	so that	it doesn't get added again the next time around

	       else

		  IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
		     fnd_message.Set_Name('PV',	'PV_DEBUG_MESSAGE');
		     fnd_message.Set_Token('TEXT', 'Reached max	partners returned: ' ||	l_match_count );
		     fnd_msg_pub.Add;
		  END IF;

		  exit;

	       end if;

	    end	if;

	 end loop;

      end loop;

      if l_combined_rank = l_rank_base_2 then

	 if l_match_count < l_top_n_rows then

	    IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
	       fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
	       fnd_message.Set_Token('TEXT', 'Rank matches.  Adding partner_id ' || partner_id);
	       fnd_msg_pub.Add;
	    END	IF;

	    l_match_count := l_match_count + 1;
	    x_matched_prt.extend;
	    x_matched_prt(l_match_count) := partner_id;

	 end if;

      else
	 if l_match_count > 0 then
	    IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
	       fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
	       fnd_message.Set_Token('TEXT', 'Did not find any more matching partner.  Exiting loop');
	       fnd_msg_pub.Add;
	    END	IF;
	    exit;
	 end if;
      end if;


   end if;


   END LOOP;

   DBMS_SQL.CLOSE_CURSOR(c => l_theCursor);
   -- ====================================================================================
   -- ====================================================================================
   -- End of processing the dynamic SQL for retrieving matching partners.
   -- ====================================================================================
   -- ====================================================================================


   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'Exiting main loop');
      fnd_msg_pub.Add;
   END IF;


   IF p_selection_criteria = g_drop_attr_match THEN

      if x_matched_prt.count = 0 then

	 l_matching_rank := l_possible_rank_high;

	 for i in 1..l_possible_match_count loop

	    if l_matching_rank = l_possible_match_rank_tbl(i) then

	       if l_match_count	< l_top_n_rows then

		  l_match_count	:= l_match_count + 1;
		  x_matched_prt.extend;
		  x_matched_prt(l_match_count) := l_possible_match_party_tbl(i);

		  IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
		     fnd_message.Set_Name('PV',	'PV_DEBUG_MESSAGE');
		     fnd_message.Set_Token('TEXT', 'Adding possible matches. Partner_id	' || l_possible_match_party_tbl(i) ||
				       ' at ' || l_possible_match_rank_tbl(i));
		     fnd_msg_pub.Add;
		  END IF;

	      else
		 exit;
	      END IF;
	   end if;

	 end loop;

      end if;

   END IF;

   -- Set flag to true / false depending on whether partners are matched or not

   if x_matched_prt.count > 0 then

      x_prt_matched := true;
      l_attr_count := 0;
      while (l_matching_rank >=	1)
      loop
	 l_attr_count := l_attr_count +	1;

	 IF p_selection_criteria	= g_drop_attr_match THEN
	    l_matching_rank := l_matching_rank / 2;
	 ELSIF p_selection_criteria = g_nodrop_attr_match THEN
	    l_matching_rank := l_matching_rank-1;
	 END IF;
      end loop;

      x_matched_attr_cnt := l_attr_count;

   else
      x_prt_matched	 := false;
      x_matched_attr_cnt := 0;
   end if;

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'Number of partners	found: ' || x_matched_prt.count	||
				    ' matched attr cnt:' || x_matched_attr_cnt);
      fnd_msg_pub.Add;
   END IF;

   IF FND_API.To_Boolean ( p_commit )	THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if	count is 1, get	message	info.
   fnd_msg_pub.Count_And_Get( p_encoded	  =>  FND_API.G_FALSE,
			      p_count	  =>  x_msg_count,
			      p_data	  =>  x_msg_data);

EXCEPTION
   WHEN	FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR ;

      fnd_msg_pub.Count_And_Get( p_encoded   =>	 FND_API.G_FALSE,
				 p_count     =>	 x_msg_count,
				 p_data	     =>	 x_msg_data);

   WHEN	FND_API.G_EXC_UNEXPECTED_ERROR THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      fnd_msg_pub.Count_And_Get( p_encoded   =>	 FND_API.G_FALSE,
				 p_count     =>	 x_msg_count,
				 p_data	     =>	 x_msg_data);

   WHEN	OTHERS THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);

      fnd_msg_pub.Count_And_Get( p_encoded   =>	 FND_API.G_FALSE,
				 p_count     =>	 x_msg_count,
				 p_data	     =>	 x_msg_data);

END Match_partner;



--=============================================================================+
--|  Procedure								       |
--|									       |
--|    Get_Matched_Partner_Details					       |
--|	   This	procedure Gets the Matched Partner Details required in the UI  |
--|									       |
--|									       |
--|									       |
--|  Parameters								       |
--|  IN									       |
--|  OUT								       |
--|									       |
--|									       |
--| NOTES								       |
--|									       |
--| HISTORY								       |
--|									       |
--==============================================================================


 /*
	 Following Assumptions are made	for the	following select statements.
	 1. Flag values	should each be a different power of 2 to ensure	that
	    each bit is	used by	only one flag.
	    Also, these	flag values should match with the flag constants defined
	    in java API	to resolve flags on the front end side.

	    REJECTED CURRENT OPPORTUNITY  = 1
	    PREFERRED OR INCUMBENT PARTNER FOR CURRENT OPPORTUNITY  = 2

	 2. Most of the	select statements assume that PT_APPROVED row for accepted
	    partner exists in pv_lead_assignments until	oppty is recycled by the partner

	 3. ISSUE : RECYCLED from_status does not have partner_id populated in
	    pv_assignment_logs.	So, rejected partner query may not give	the correct result

	    PROPOSAL :	We need	to identify an assignment status when partner is
			rejecting an oppty

	    after accepting it . Then, we can populate	partner_id in logs table
	    to identify	rejected partner

 */



 Procedure Get_Matched_Partner_Details(
	 p_api_version_number	 IN  NUMBER,
	 p_init_msg_list	 IN  VARCHAR2 := FND_API.G_FALSE,
	 p_commit		 IN  VARCHAR2 := FND_API.G_FALSE,
	 p_validation_level	 IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
	 p_lead_id		 IN  NUMBER,
	 p_extra_partner_details IN  JTF_VARCHAR2_TABLE_1000,
	 p_matched_id		 IN  OUT NOCOPY JTF_NUMBER_TABLE,
	 x_partner_details	 OUT NOCOPY 	JTF_VARCHAR2_TABLE_4000,
	 x_flagcount		 OUT NOCOPY 	JTF_VARCHAR2_TABLE_100,
	 x_return_status	 OUT NOCOPY 	VARCHAR2,
	 x_msg_count		 OUT NOCOPY 	NUMBER,
	 x_msg_data		 OUT NOCOPY 	VARCHAR2)  IS

--   ACTIVE_OPPTY_FLAG		CONSTANT NUMBER	:= 1;
--   CLOSED_DEALS_FLAG		CONSTANT NUMBER	:= 2;
   REJECTED_OPPTY_FLAG		CONSTANT NUMBER	:= 1;
   INCUMBENT_PARTNER_FLAG	CONSTANT NUMBER	:= 2;
   TOKEN			CONSTANT VARCHAR2(3) :=	'~';
   NULLTOKEN			CONSTANT VARCHAR2(3) :=	'===';
   l_party_name			varchar2(360);
   l_city			varchar2(60);
   l_state			varchar2(60);
   l_country			varchar2(60);
   l_postal_code		varchar2(60);
   l_address1			varchar2(1000);
   l_address2			varchar2(240);
   l_address3			varchar2(240);
   l_attr_desc			varchar2(60);
   l_partner_id			number;
   l_oppty_last_offer_dt	varchar2(20);
   l_party_id			number;
   l_partner_count		Number	:= 0;
   l_flag_count			number	:= 0;
   l_incumbent_pt_party_id	number;
   l_incumbent_exists_flag	boolean;
   l_relationship_id		NUMBER;
   l_partner_name		VARCHAR2(3600);
   l_internal_org_name		VARCHAR2(3600);
   l_internal_flag		VARCHAR2(1);
   l_party_flag			VARCHAR2(1);
   l_partner_names		VARCHAR2(3600);
   l_partner_id_tbl		JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_count			NUMBER;
   l_wf_status			VARCHAR2(1000);
   l_active_flag		VARCHAR2(1);
   l_partner_detail_sql         VARCHAR2(4000);

   Type partner_det_rec is REF CURSOR;

   lc_partner_detail_cur partner_det_rec;


   Type	l_tmp is Table of Varchar2(4000) index by binary_integer;

   l_tmp_ids_tbl		l_tmp;
   l_tmp_pt_details_tbl		l_tmp;

   l_incumbent_party_name	VARCHAR2(3600);

   cursor lc_get_incumbent_pt (pc_lead_id number) is
      select asla.INCUMBENT_PARTNER_PARTY_ID
      from as_leads_all	asla
      where asla.lead_id = pc_lead_id;


   cursor lc_get_flag_count(pc_lead_id number ,	pc_partner_id number ,
			    pc_incumbent_pt_party_id number,
			    rejected_oppty_flag	number,
			    incumbent_partner_flag number)  is
      select sum(flagvalue) flagcount
      from (
	select	rejected_oppty_flag flagvalue
	from	dual
	where	exists
	(select	 rejected_oppty_flag
	 from	 pv_lead_assignments pval
	 where	 pval.lead_id =	pc_lead_id
	  and	 pval.status in	('PT_REJECTED',	'PT_ABANDONED',	'PT_TIMEOUT')
	  and	 pval.partner_id = pc_partner_id
	)
	union
	select incumbent_partner_flag flagvalue
	from   dual
	where  pc_partner_id = pc_incumbent_pt_party_id
	);

   cursor lc_duplicate_pt_count
   IS
   select  pvpp.partner_id,
           hzp.party_name,
           hzop_pt.internal_flag pt_int_flag,
           vend.party_name,
           hzop_vend.internal_flag vend_int_flag
   from    hz_parties hzp , pv_partner_profiles pvpp , hz_parties vend,
           hz_relationships hzr,
           hz_organization_profiles HZOP_pt,
           hz_organization_profiles hzop_vend
   where   hzr.party_id = pvpp.partner_id
   and     pvpp.partner_party_id = hzr.subject_id
   and     hzr.subject_id = hzp.party_id
   and     hzr.subject_table_name = 'HZ_PARTIES'
   and     hzr.object_table_name = 'HZ_PARTIES'
   and     hzr.status = 'A' and hzr.start_date <= sysdate and nvl(hzr.end_date,sysdate) >= sysdate
   and     hzr.subject_id = HZOP_pt.party_id and nvl(hzop_pt.effective_end_date,sysdate) >= sysdate
   and     hzr.object_id = HZOP_vend.party_id and nvl(hzop_vend.effective_end_date,sysdate) >= sysdate
   and     (HZOP_vend.internal_flag   = 'N' or hzop_pt.internal_flag = 'Y')
   and     pvpp.partner_id in (
		SELECT * FROM TABLE (CAST(p_matched_id AS JTF_NUMBER_TABLE))
		)
   and     hzr.object_id = vend.party_id
   and     hzr.relationship_code in ('PARTNER_OF','VAD_OF');

   -- =================================================================================
   -- When the Partner Status is Inactive OR Relationship status is inactive
   -- OR if the relationship is end dated OR if the Vendor ORG is end dated
   -- then the active_flag's value would be 'Inactive'
   -- Uncomment this when the local databases are upgraded to 9i
   -- =================================================================================


/*
   -- 11.5.9
   CURSOR l_partner_detail_cur
   IS
      select  hzp.party_name, hzp.city,	 hzp.state ,
	      hzp.postal_code, hzp.country, hzp.address1,
	      hzp.address2, hzp.address3, hzp.party_id,
	      pvpp.partner_id,
	      to_char(pvpp.OPPTY_LAST_OFFERED_DATE, 'YYYY-MM-DD	HH:MM:SS'),
	      pvac.description,	hzr.relationship_id,
	      (case when hzp.status = 'A'
	       and  hzr.status = 'A'
	       and nvl(hzop.effective_start_date, sysdate) <= sysdate
	       and nvl(hzop.effective_end_date,	sysdate) >= sysdate
	       and hzr.start_date <= SYSDATE and NVL(hzr.end_date,SYSDATE) >= SYSDATE
	       then 'A'
	       else 'I'
	       end ) active_flag
      from    hz_parties hzp , pv_partner_profiles pvpp	,
	      pv_attribute_codes_vl  pvac, hz_relationships hzr	,
	      hz_organization_profiles HZOP,
	     (SELECT rownum idx, column_value
	      FROM   (SELECT column_value FROM TABLE (CAST(p_matched_id	AS JTF_NUMBER_TABLE))))	x_partner
      where   pvpp_partner_id in (SELECT * FROM THE(select CAST(p_matched_id AS JTF_NUMBER_TABLE) from dual))
      and     pvpp.partner_id =	x_partner.column_value
      and     hzr.party_id = pvpp.partner_id
      and     hzr.subject_id = hzp.party_id
      and     hzr.object_id = HZOP.party_id
      and     HZOP.internal_flag   = 'Y'
      and     hzr.subject_table_name = 'HZ_PARTIES'
      and     hzr.object_table_name = 'HZ_PARTIES'
      and     pvpp.PARTNER_LEVEL = pvac.attr_code_id(+)
      order   by x_partner.idx;

   -- 11.5.10 -- pklin
   CURSOR l_partner_detail_cur
   IS
      select  hzp.party_name, hzp.city,	 hzp.state ,
	      hzp.postal_code, hzp.country, hzp.address1,
	      hzp.address2, hzp.address3, hzp.party_id,
	      pvpp.partner_id,
	      to_char(pvpp.OPPTY_LAST_OFFERED_DATE, 'YYYY-MM-DD	HH:MM:SS'),
	      pvac.description,
              pvpp.status active_flag
      from    hz_parties hzp,
              pv_partner_profiles pvpp,
	      pv_attribute_codes_vl pvac,
	     (SELECT rownum idx, column_value
	      FROM   (SELECT column_value FROM TABLE (CAST(p_matched_id	AS JTF_NUMBER_TABLE))))	x_partner
      where   pvpp.partner_id =	x_partner.column_value
      and     pvpp.partner_party_id = hzp.party_id
      and     pvpp.PARTNER_LEVEL = pvac.attr_code_id(+)
      order   by x_partner.idx;
*/



/*   CURSOR lc_get_pt_org_name(lc_partner_id NUMBER)
   IS
   select distinct party_name
   from	  hz_relationships hzr,
	  hz_parties hzp,
	  hz_organization_profiles HZOP
   where  hzr.subject_id = hzp.party_id
   and	  hzr.object_id	= HZOP.party_id
   and	  HZOP.internal_flag   = 'Y'
   and	  hzr.subject_table_name = 'HZ_PARTIES'
   and	  hzr.object_table_name	= 'HZ_PARTIES'
   and	  hzr.party_id = lc_partner_id; */

   l_pt_id		 NUMBER;
   l_pt_count		 NUMBER;
   l_api_name		 CONSTANT VARCHAR2(30) := 'Get_Matched_Partner_Details';
   l_api_version_number	 CONSTANT NUMBER       := 1.0;


Begin

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'In	' || l_api_name);
      fnd_msg_pub.Add;
   END IF;

   -- Standard call to check for call compatibility.

   IF NOT FND_API.Compatible_API_Call (l_api_version_number,
				       p_api_version_number,
				       l_api_name,
				       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   END IF;

   -- Initialize message list if p_init_msg_list is set	to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      fnd_msg_pub.initialize;
   END IF;

   x_flagcount		 :=  JTF_VARCHAR2_TABLE_100();
   x_partner_details	 :=  JTF_VARCHAR2_TABLE_4000();

   x_return_status	 :=  FND_API.G_RET_STS_SUCCESS ;


   -- to be removed later
   -- =============================================================================
   -- Main Aim of this SQL being dynamic is PL/SQL 8i does not support CASE WHEN.
   -- But since the parser of 9i is same for PL/SQL engine and SQL engine
   -- CASE WHEN is supported in 9i. Once the local databases are upgraded to 9i
   -- this SQL should be a static cursor instead of dynamic.
   -- =============================================================================
   -- Modified by pklin for 11.5.10. No need to join to hz_relationships and
   -- hz_organization_profiles to get the "active_flag". pv_partner_profile.status
   -- now contains the denormalized data that indicate whether a partner record
   -- is active or not.
   --
   -- Modified by pklin on 8/6/04 to add additional tables to the use_nl hint.
   -- Original hint: use_nl(x_partner)
   -- Revised  hint: use_nl(x_partner pvpp hzp pvac)
   --
   -- Also the use of pv_attribute_codes_vl has been modified to use the base
   -- table pv_attribute_codes_tl instead.
   -- -----------------------------------------------------------------------------

   l_partner_detail_sql  :=
           'select  /*+ leading(x_partner) use_nl(x_partner pvpp hzp pvac) */ ' ||
           'hzp.party_name, hzp.city, hzp.state , '||
	   'hzp.postal_code, hzp.country, hzp.address1, hzp.address2, hzp.address3, '||
	   'hzp.party_id, pvpp.partner_id, pvac.description, '||
	   'to_char(pvpp.oppty_last_offered_date, ''YYYY-MM-DD HH:MI:SS''), '||
           'pvpp.status active_flag ' ||
	   'from  hz_parties hzp , pv_partner_profiles pvpp, pv_attribute_codes_tl  pvac, '||
	   '(SELECT rownum idx, column_value FROM  '||
	   '(SELECT column_value FROM TABLE (CAST(:1 AS JTF_NUMBER_TABLE))))	x_partner '||
	   'where pvpp.partner_id = x_partner.column_value ' ||
           'and   pvpp.partner_party_id = hzp.party_id ' ||
           'and   pvpp.PARTNER_LEVEL = pvac.attr_code_id(+) '||
	   'and   pvac.language(+) = USERENV(''LANG'') ' ||
	   'order   by x_partner.idx ';



      for i in 1..ceil((length(l_partner_detail_sql)/100)) loop
	 IF fnd_msg_pub.Check_Msg_Level	(fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
	    fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
	    fnd_message.Set_Token('TEXT', substr(l_partner_detail_sql, (i-1)*100+1, 100));
	    fnd_msg_pub.Add;
	 END IF;
      end loop;

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
	   debug('Partner Id count before getting details '||p_matched_id.count);
    END IF;

   if (p_matched_id.count > 0) then

      open lc_partner_detail_cur for l_partner_detail_sql using p_matched_id;

      loop
	 fetch lc_partner_detail_cur into  l_party_name,l_city,	l_state,
					  l_postal_code, l_country,l_address1,
					  l_address2, l_address3,l_party_id,
					  l_partner_id,  l_attr_desc,
					  l_oppty_last_offer_dt,l_active_flag;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
           debug('Row Count of details '||lc_partner_detail_cur%ROWCOUNT);
        END IF;

	 exit when lc_partner_detail_cur%NOTFOUND;

	 IF fnd_msg_pub.Check_Msg_Level	(fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN

	    fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
	    fnd_message.Set_Token('TEXT', ' l_partner_id  : ' || l_partner_id || fnd_global.local_chr(10) ||
					  ' l_party_id	  : ' || l_party_id || fnd_global.local_chr(10)	||
					  ' l_attr_desc	  : ' || l_attr_desc ||	fnd_global.local_chr(10) ||
					  ' l_party_name  : ' || l_party_name || fnd_global.local_chr(10) ||
					  ' l_oppty_last_offer_dt: ' ||	l_oppty_last_offer_dt||	fnd_global.local_chr(10) ||
					  ' l_active_flag    : '|| l_active_flag);
	    fnd_msg_pub.Add;

	    fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
	    fnd_message.Set_Token('TEXT', ' l_city	  : ' || l_city	|| fnd_global.local_chr(10) ||
					  ' l_state	  : ' || l_state || fnd_global.local_chr(10) ||
					  ' l_postal_code : ' || l_postal_code || fnd_global.local_chr(10) ||
					  ' l_country	  : ' || l_country || fnd_global.local_chr(10) ||
					  ' l_address1	  : ' || l_address1 || fnd_global.local_chr(10)	||
					  ' l_address2	  : ' || l_address2 || fnd_global.local_chr(10)	||
					  ' l_address3	  : ' || l_address3 || fnd_global.local_chr(10));
	    fnd_msg_pub.Add;

	 END IF;

	 if  l_address1	is not	null then
	     l_address1	:= l_address1 || ',';
	 end if;

	 if l_address2 is not null then
	    l_address1 := l_address1  || l_address2 || ',';
	 end if;

	 if l_address3 is not null then
	     l_address1	:= l_address1 || l_address3 || ',';
	 end if;

	 if l_city is not null then
	     l_address1	:= l_address1  || l_city || ',';
	 end if;

	 if l_state is not null	then
	     l_address1	:= l_address1 || l_state || ',';
	 end if;

	 if l_country is not null then
	     l_address1	:= l_address1 || l_country || ',';
	 end if;

	 if l_postal_code is not null then
	     l_address1	:= l_address1 || l_postal_code || ',' ;
	 end if;

	 if l_address1 is not null then
	     l_address1	:=   replace(substr(l_address1,	1, length(l_address1) -	1), '~', '^');
	 else
	     l_address1	:= NULLTOKEN;
	 end if;

	 if l_party_name is null then
	   l_party_name	:= NULLTOKEN;
	 else
	   l_party_name	:= replace(l_party_name, '~', '^');
	 end if;

	 if l_attr_desc	is null	then
	   l_attr_desc := NULLTOKEN;
	 end if;

	 if l_oppty_last_offer_dt is null then
	    l_oppty_last_offer_dt := NULLTOKEN;
	 end if;

	 IF fnd_msg_pub.Check_Msg_Level	(fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
	    fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
	    fnd_message.Set_Token('TEXT', 'Appended Address String : ');
	    fnd_msg_pub.Add;
	 END IF;

	 for i in 1..ceil((length(l_address1)/100)) loop
	    IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
	       fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
	       fnd_message.Set_Token('TEXT', substr(l_address1,	(i-1)*100+1, 100));
	       fnd_msg_pub.Add;
	    END	IF;
	 end loop;

	 l_partner_count := l_partner_count + 1;
	 l_tmp_ids_tbl(l_partner_count)	:= l_partner_id;


	 l_tmp_pt_details_tbl(l_partner_count) := l_party_name || TOKEN	 || l_party_id	 || TOKEN  || l_partner_id  ||
						  TOKEN	 || l_address1	 || TOKEN  || l_attr_desc  || TOKEN  ||
						  l_oppty_last_offer_dt	||TOKEN ||
						  l_active_flag || TOKEN;

         IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN

	    Debug('Appended Matched Partner Info :	');


	    for i in 1..ceil((length(l_tmp_pt_details_tbl(l_partner_count))/100)) loop
	       Debug('Partner id '||substr( l_tmp_pt_details_tbl(l_partner_count),(i-1)*100+1, 100));
	    end loop;
        END IF;


      end loop;

      close lc_partner_detail_cur;

      IF p_matched_id.count = l_tmp_ids_tbl.count THEN

	 x_partner_details.extend(p_matched_id.count);

      ELSE

	l_partner_names := NULL;

	OPEN  lc_duplicate_pt_count;
	LOOP
	    FETCH lc_duplicate_pt_count	INTO l_pt_id, l_partner_name, l_party_flag, l_internal_org_name, l_internal_flag;
       	    EXIT WHEN lc_duplicate_pt_count%NOTFOUND;

	    IF l_party_flag = 'Y' THEN

              IF l_party_flag = l_internal_flag THEN


		  IF l_partner_names is	NULL THEN
		     l_partner_names :=	 l_partner_name	;
		  ELSE
		     l_partner_names :=	l_partner_names	|| ' ,	' || l_partner_name ;
		  END IF;


              END IF;

	    END	IF;



	 END LOOP;
	 CLOSE lc_duplicate_pt_count;

	 IF l_party_flag = 'Y' THEN

            IF l_party_flag = l_internal_flag and l_partner_names is not null THEN

	       fnd_message.Set_Name('PV', 'PV_WRONG_INTRNL_ORG');
	       fnd_message.Set_Token('P_PT_NAMES', l_partner_names);
	       fnd_msg_pub.Add;


	       raise FND_API.G_EXC_ERROR;


             END IF;

	  END IF;


     END IF;


      for i in 1 .. l_tmp_ids_tbl.count	loop

	  IF (g_from_match_lov_flag) THEN -- For Matching Rows


  	      x_partner_details(i) := l_tmp_pt_details_tbl(i) || 'MATCHING';



	  ELSE -- For submitted	routing	rows

	   IF	p_extra_partner_details.count =	0 THEN

		x_partner_details(i) :=	l_tmp_pt_details_tbl(i);
	   ELSE

		x_partner_details(i) :=	l_tmp_pt_details_tbl(i)	|| p_extra_partner_details(i);

	   END IF;

	  END IF;

      END LOOP;


      -- Reinitializaing matched ID table

      p_matched_id.delete;


      for k in 1..l_tmp_ids_tbl.count loop

	  p_matched_id.extend;
	  p_matched_id(p_matched_id.count) := l_tmp_ids_tbl(k);

      end loop;

      open lc_get_incumbent_pt (p_lead_id);
      fetch lc_get_incumbent_pt	into l_incumbent_pt_party_id;

       if l_incumbent_pt_party_id is  null then

	  IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
	     fnd_message.Set_Name('PV',	'PV_DEBUG_MESSAGE');
	     fnd_message.Set_Token('TEXT', 'Incumbent Partner party ID is null.	So, setting it to be zero');
	     fnd_msg_pub.Add;
	  END IF;

	  l_incumbent_pt_party_id := 0;
	end if;


      close lc_get_incumbent_pt;

      IF l_tmp_ids_tbl.count > 0 THEN

	 for i in l_tmp_ids_tbl.first .. l_tmp_ids_tbl.last loop

	   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
	      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
	      fnd_message.Set_Token('TEXT', 'Looking for Flag count for	Partner	Id : ' || l_tmp_ids_tbl(i));
	      fnd_msg_pub.Add;
	   END IF;

	   open lc_get_flag_count(p_lead_id, l_tmp_ids_tbl(i), l_incumbent_pt_party_id, REJECTED_OPPTY_FLAG, INCUMBENT_PARTNER_FLAG);
	   fetch lc_get_flag_count into l_flag_count;

	   x_flagcount.extend;

 	   if   lc_get_flag_count%found
	   and  l_flag_count is	not null then
	      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
		 Debug( 'flag Count : ' ||	l_flag_count);
              END IF;
	      x_flagcount(i) :=  l_flag_count;
	   else
	      x_flagcount(i) := 0;
	   end if;

	   l_flag_count := 0;
	   close lc_get_flag_count;

       end loop;

    end if;

 end if;

 IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN

    For i in 1 .. p_matched_id.count
    Loop
      Debug('Partner ID from p_matched_id tbl	: ' || p_matched_id(i));
    end loop;

    Debug('end of partner details : ' );
 END IF;

 IF FND_API.To_Boolean ( p_commit )	THEN
    COMMIT WORK;
 END IF;

   -- Standard call to get message count and if	count is 1, get	message	info.
 fnd_msg_pub.Count_And_Get( p_encoded	  =>  FND_API.G_FALSE,
	    p_count	=>  x_msg_count,
	    p_data	=>  x_msg_data);
EXCEPTION

   WHEN	FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>	 FND_API.G_FALSE,
				 p_count     =>	 x_msg_count,
				 p_data	     =>	 x_msg_data);

   WHEN	FND_API.G_EXC_UNEXPECTED_ERROR THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      fnd_msg_pub.Count_And_Get( p_encoded   =>	 FND_API.G_FALSE,
				 p_count     =>	 x_msg_count,
				 p_data	     =>	 x_msg_data);

   WHEN	OTHERS THEN


      x_return_status :=	FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);

      fnd_msg_pub.Count_And_Get( p_encoded   =>	 FND_API.G_FALSE,
				 p_count     =>	 x_msg_count,
				 p_data	     =>	 x_msg_data);

End get_matched_partner_details;



/*************************************************************************************/

/*				 public	routines				     */
/*										     */
/*************************************************************************************/
-- pklin

--=============================================================================+
--|  Procedure								       |
--|									       |
--|    Get_Assigned_Partners						       |
--|    This procedure Gets the Assigned	Partner	and their details required     |
--|    in UI								       |
--|									       |
--|									       |
--|  Parameters								       |
--|  IN									       |
--|  OUT								       |
--|									       |
--|									       |
--| NOTES								       |
--|									       |
--| HISTORY								       |
--|									       |
--==============================================================================

 Procedure Get_Assigned_Partners(
	 p_api_version_number	 IN  NUMBER,
	 p_init_msg_list	 IN  VARCHAR2 := FND_API.G_FALSE,
	 p_commit		 IN  VARCHAR2 := FND_API.G_FALSE,
	 p_validation_level	 IN  NUMBER	  := FND_API.G_VALID_LEVEL_FULL,
	 p_lead_id		 IN  NUMBER,
	 p_resource_id		 IN  NUMBER,
	 x_assigned_partner_id	 OUT NOCOPY JTF_NUMBER_TABLE,
	 x_partner_details	 OUT NOCOPY JTF_VARCHAR2_TABLE_4000,
	 x_flagcount		 OUT NOCOPY JTF_VARCHAR2_TABLE_100,
	 x_return_status	 OUT NOCOPY VARCHAR2,
	 x_msg_count		 OUT NOCOPY NUMBER,
	 x_msg_data		 OUT NOCOPY VARCHAR2)  IS

      TOKEN			 CONSTANT VARCHAR2(3) := '~';
      NULLTOKEN			 CONSTANT VARCHAR2(3) := '===';
      DUMMY_NUMBER		 CONSTANT NUMBER := 99999999999;
      Type assignment_rec is REF CURSOR;

      assignment_cur		  assignment_rec;
      l_tmp_tbl			  JTF_VARCHAR2_TABLE_1000;
      l_tmp			 varchar2(10);
      l_incumbent_pt_party_id	  number;
      l_assignment_started	  varchar2(1000);
      l_assigned_partners	  varchar2(2000);
      l_response		  varchar2(30);
      l_resource_id		   Number;
      l_primary_key		   Number;
      l_response_date		   varchar2(20);
      l_source			  varchar2(10);
      l_lock_flag		  varchar2(1);
      l_partnerid		  number;
      l_tmp_partnerid		  number := 0;
      l_previous_pt_count	  number;
      l_partner_cnt_pt_id	  number;
      l_party_reltn_type	  varchar2(100);
      l_object_id		  number;
      l_partner_count		  number := 1;
      l_pt_flag			  boolean := false;
      l_duplicate_pt		  boolean := false;
      l_wf_started		  varchar2(30) ;
      l_decision_maker		  varchar2(1);
      l_assign_sequence		  number;
      l_routing_status            varchar2(30);
      l_wf_status                 varchar2(30);

      cursor lc_get_lead_status ( pc_lead_id NUMBER) is
	select wf_status, routing_status
	from   pv_lead_workflows
	where  lead_id = pc_lead_id
	and    latest_routing_flag = 'Y';

      cursor lc_id_type	(pc_party_rel_id number) is
	    select
	    pr.relationship_type,
	    pr.object_id
	    from   hz_relationships pr,
	     hz_parties	pt
	    where pr.party_id		= pc_party_rel_id
	    AND	  pr.subject_table_name	= 'HZ_PARTIES'
	    AND	  pr.object_table_name	= 'HZ_PARTIES'
	    AND	  pr.directional_flag	= 'F'
	    and	  pr.subject_id		= pt.party_id;




      cursor lc_get_routed_partners (pc_lead_id number)
      is
        select   PVLA.PARTNER_ID, PVPN.RESOURCE_ID, 'PN' source ,
	         PVLA.STATUS, to_char(PVLA.STATUS_DATE, 'YYYY-MM-DD HH:MM:SS'),
		 pvpn.DECISION_MAKER_FLAG
        from     PV_LEAD_ASSIGNMENTS PVLA,
		 PV_PARTY_NOTIFICATIONS	PVPN,
		 PV_LEAD_WORKFLOWS	PVLW
        where    pvlw.LEAD_ID = pc_lead_id
	and      pvlw.LATEST_ROUTING_FLAG	= 'Y'
	and      pvlw.WF_ITEM_KEY	= pvla.WF_ITEM_KEY
	and      pvlw.WF_ITEM_TYPE = pvla.WF_ITEM_TYPE
	and      PVLA.LEAD_ASSIGNMENT_ID = PVPN.LEAD_ASSIGNMENT_ID(+)
	and      PVPN.NOTIFICATION_TYPE(+) = 'MATCHED_TO'
	ORDER BY PVLA.ASSIGN_SEQUENCE, PVLA.PARTNER_ID;

     cursor lc_get_matched_partners (pc_lead_id number)
     is
	select  asac.partner_customer_id ,
		'SALESTEAM' source , access_id,	99999999999
	from    as_accesses asac
	where   asac.lead_id = pc_lead_id
	and     asac.sales_lead_id is null
	and    (asac.partner_cont_party_id  is not null
	or      asac.partner_customer_id  is not null )
	union
	select pvla.partner_id partner_id, pvla.source_type source
	     , lead_assignment_id ,pvla.assign_sequence
	from   pv_lead_assignments pvla
	where  pvla.lead_id = pc_lead_id
	and    pvla.status = 'UNASSIGNED'
	order by 4;


      l_api_name	    CONSTANT VARCHAR2(30) := 'Get_Assigned_Partners';
      l_api_version_number  CONSTANT NUMBER	  := 1.0;

Begin
   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'In	' || l_api_name	|| '. Lead id: ' || p_lead_id );
      fnd_msg_pub.Add;
   END IF;

   -- Standard call to check for call compatibility.

   IF NOT FND_API.Compatible_API_Call (l_api_version_number,
				       p_api_version_number,
				       l_api_name,
				       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set	to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      fnd_msg_pub.initialize;
   END IF;

   l_tmp_tbl		   :=  JTF_VARCHAR2_TABLE_1000();
   x_flagcount		   :=  JTF_VARCHAR2_TABLE_100();
   x_partner_details	   :=  JTF_VARCHAR2_TABLE_4000();
   x_assigned_partner_id   :=  JTF_NUMBER_TABLE();
   x_return_status	   :=  FND_API.G_RET_STS_SUCCESS ;

   /**
	 p_wf_started value passed into	the API	has to be either Y or N.
	 All other values are ignored.
   **/


   open  lc_get_lead_status(p_lead_id);
   loop
      fetch lc_get_lead_status into l_wf_status, l_routing_status;

       IF lc_get_lead_status%ROWCOUNT	> 1 THEN
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
 	     debug('There should be only one row in the lead workflows table. Check.........');
          END IF;
       END IF;

       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
          debug('Wf Started '||l_wf_started);
       END IF;

       IF   l_wf_status = 'CLOSED'
       AND  l_routing_status in ( 'UNASSIGNED', 'ABANDONED','FAILED_AUTO_ASSIGN', 'WITHDRAWN', 'RECYCLED')
       THEN
            l_wf_started := 'N';
       ELSIF l_wf_status is null
       AND l_routing_status is null THEN
            l_wf_started := 'N';
       ELSIF l_wf_status = 'OPEN' THEN
            l_wf_started := 'Y';
       ELSE
           l_wf_started := 'Y';
       END IF;
       exit when lc_get_lead_status%NOTFOUND;
   end loop;
   close lc_get_lead_status;


   if l_wf_started = 'Y' then

       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
	  Debug('WorkFlow is not started for '|| ' Lead ID: '||  p_lead_id);
       END IF;


      open lc_get_routed_partners(p_lead_id);

      loop
	 fetch lc_get_routed_partners  into l_partnerid, l_resource_id,	l_source,
				 l_response, l_response_date , l_decision_maker;

	 exit when lc_get_routed_partners%notfound;

         IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
	    Debug( 'partner count : ' ||l_partner_count);
         END IF;


	 if l_resource_id is null then
	    l_resource_id :=DUMMY_NUMBER;
	 end if;

	 if l_tmp_partnerid   <>  l_partnerid then

	    if l_partner_count > 1 then
	       for x in	l_previous_pt_count ..l_tmp_tbl.count  loop
		  l_tmp_tbl(x) := l_tmp_tbl(x) || l_lock_flag;
	       end loop;
	    end	if;

	    l_tmp_partnerid    := l_partnerid;
	    l_lock_flag	       := 'Y';
	    l_duplicate_pt     := false;
	    l_previous_pt_count	:= l_partner_count;

	    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
               Debug('Prtnr Changed. Tmp Pt ID:' || L_tmp_partnerid || '  pt id: ' ||l_partnerid);
	       Debug('previous pt count	: '  ||	l_previous_pt_count || '. Lock Flag : '	|| l_lock_flag);
	    END IF;


	 else
	    l_duplicate_pt	:= true;
	 end if;

	 if l_lock_flag	= 'Y' then

	    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
	       debug('l_resource_id : '	|| l_resource_id || ' p_resource_id : '	|| p_resource_id);
	       debug('l_decision_maker : ' || l_decision_maker);
	    END IF;

	    if (l_resource_id =	p_resource_id and l_response <>	'CM_APP_FOR_PT'	and l_response <> 'CM_ADD_APP_FOR_PT'
	    and	l_response <> 'CM_REJECTED' and	l_response <> 'PT_APPROVED' and l_decision_maker = 'Y')	 then
	       l_lock_flag := 'N';
	    else
	       l_lock_flag := 'Y';
	    end	if;

	 end if;

	 if  not l_duplicate_pt	 then

	    if l_response is null then
	       l_response := NULLTOKEN;
	    end	if;

	    if l_response_date is null then
	       l_response_date := NULLTOKEN;
	    end	if;

	    if l_source	is null	then
	       l_source	:= NULLTOKEN;
	    end	if;

	    l_tmp_tbl.extend;
	    l_tmp_tbl(l_partner_count) :=  l_source || TOKEN ||	DUMMY_NUMBER ||	TOKEN || l_response || TOKEN ||
					   l_response_date || TOKEN ;

	    x_assigned_partner_id.extend;
	    x_assigned_partner_id(l_partner_count) := l_partnerid;

	    l_partner_count := l_partner_count + 1;

	 end if;

      end loop;

      if l_partner_count > 1 then
	 for x in l_previous_pt_count ..l_tmp_tbl.count	 loop
	     l_tmp_tbl(x) := l_tmp_tbl(x) || l_lock_flag;
	 end loop;
      end if;

      close lc_get_routed_partners;


   elsif l_wf_started ='N' then

      /**
      **  Submit Routing in UI will save all the partners in pv_lead_assignments
      **  If there is an error in creating the assignment, we can't roll back the above	as they	are part of two	separate
      **  transactions in UI. So, when users gets back to  assignment detail UI	page, we'll like do our	original logic.
      **  i.e. Get Partnes from	Sales Team and partners	that are saved from matching.
      **  we would n't want to get sales team partners from pv_lead_assignments
      **/

      -- Commenting out this delete statement as a fix for the ranking issue if the partners
      -- came from salesteam. The salesteam rows were being deleted and then queried from
      -- the as_accesses_all table. Because of this we could never rank the partners added
      -- from salesteam. This change in conjunction with a change in the java layer gets us
      -- the desired result. Please refer to bug 3614435 for more details.
      /*
      delete from pv_lead_assignments
      where lead_id = p_lead_id
      and   source_type	= 'SALESTEAM'
      and   status = 'UNASSIGNED';
      */

      /**
      if(SQL%Found) then
	 fnd_message.SET_NAME  ('PV', 'Just Deleted' ||	SQL%ROWCOUNT);
	 fnd_msg_pub.ADD;

	 raise FND_API.G_EXC_ERROR;
       end if;
      **/
	    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
		 Debug('WorkFlow is not started for '|| ' Lead ID: '||  p_lead_id);
	    END IF;




      open lc_get_matched_partners(p_lead_id);

      loop
	 fetch lc_get_matched_partners  into l_partnerid,  l_source, l_primary_key, l_assign_sequence;

	 exit when lc_get_matched_partners%notfound;

	 IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
	    Debug('partner id :' || l_partnerid );
	 END IF;

	 IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
 	    Debug( 'Source ' || l_source|| ' primary key : ' ||l_primary_key||' assign sequence :' ||l_assign_sequence);
         END IF;

	 if l_partnerid	is not null then
	    open lc_id_type(l_partnerid);

	    fetch lc_id_type into l_party_reltn_type, l_object_id ;

	    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
		Debug('Party Relationship Type : '|| l_party_reltn_type || ' Object ID : '  || l_object_id);
	    END IF;



	    if lc_id_type%found and l_party_reltn_type is not null then

	       if (l_party_reltn_type = 'PARTNER' or l_party_reltn_type = 'VAD') then

	           l_pt_flag := true;

	       end if;

 	    end if;
	    close lc_id_type;
	 end if;

	 if x_assigned_partner_id.count	> 0 then

	    for	i in x_assigned_partner_id.FIRST ..x_assigned_partner_id.LAST loop

	       if x_assigned_partner_id(i) = l_partnerid then
		  l_duplicate_pt := true;

		    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
			Debug('Duplicate Partner');
		    END IF;


	       end if;

	    end	loop;

	 end if;

	 if  (not l_duplicate_pt) AND l_pt_flag	 then

	    l_tmp_tbl.extend;
	    l_tmp_tbl(l_partner_count) := l_source || TOKEN || l_primary_key ||	TOKEN;

	    x_assigned_partner_id.extend;
	    x_assigned_partner_id(l_partner_count) := l_partnerid;

	    l_partner_count := l_partner_count + 1;

	 end if;
	 l_duplicate_pt	:= false;
	 l_pt_flag := false;

      end loop;

      close lc_get_matched_partners;

   end if;

   IF x_assigned_partner_id.count > 0 then

      g_from_match_lov_flag := FALSE;
      Get_Matched_Partner_Details(
	 p_api_version_number	  => 1.0
	 ,p_init_msg_list	   => FND_API.G_FALSE
	 ,p_commit		   => FND_API.G_FALSE
	 ,p_validation_level	   => FND_API.G_VALID_LEVEL_FULL
	 ,p_lead_id		   => p_lead_id
	 ,p_extra_partner_details  => l_tmp_tbl
	 ,p_matched_id		   => x_assigned_partner_id
	 ,x_partner_details	   => x_partner_details
	 ,x_flagcount		   => x_flagcount
	 ,x_return_status	   => x_return_status
	 ,x_msg_count		   => x_msg_count
	 ,x_msg_data		   => x_msg_data);

	IF (x_return_status = fnd_api.g_ret_sts_error) THEN
	      RAISE fnd_api.g_exc_error;
	ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error)	THEN
	      RAISE fnd_api.g_exc_unexpected_error;
	END IF;

	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
	    Debug('# of Partners Returned from matched_partner_details: ' || x_assigned_partner_id.COUNT);
	END IF;


	for i in 1 .. l_tmp_tbl.count
	loop
	   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
	    debug('Extra Partner Details  :('||i ||' )'||l_tmp_tbl(i));
	   END IF;

	end loop;

   END IF;

   IF FND_API.To_Boolean ( p_commit )	THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if	count is 1, get	message	info.
   fnd_msg_pub.Count_And_Get( p_encoded	  =>  FND_API.G_FALSE,
	    p_count	=>  x_msg_count,
	    p_data	=>  x_msg_data);
EXCEPTION

   WHEN	FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR ;

      fnd_msg_pub.Count_And_Get( p_encoded   =>	 FND_API.G_FALSE,
	       p_count	   =>  x_msg_count,
				 p_data	     =>	 x_msg_data);

   WHEN	FND_API.G_EXC_UNEXPECTED_ERROR THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      fnd_msg_pub.Count_And_Get( p_encoded   =>	 FND_API.G_FALSE,
				 p_count     =>	 x_msg_count,
				 p_data	     =>	 x_msg_data);

   WHEN	OTHERS THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);

      fnd_msg_pub.Count_And_Get( p_encoded   =>	 FND_API.G_FALSE,
				 p_count     =>	 x_msg_count,
				 p_data	     =>	 x_msg_data);

End Get_Assigned_partners;



--=============================================================================+
--|  Procedure								       |
--|									       |
--|	Create_Assignment |
--|    This procedure Gets the Assigned	Partner	and their details required     |
--|    in UI								       |
--|									       |
--|									       |
--|  Parameters								       |
--|  IN									       |
--|  OUT								       |
--|									       |
--|									       |
--| NOTES								       |
--|									       |
--| HISTORY								       |
--|									       |
--==============================================================================


 Procedure Create_Assignment(
      P_API_VERSION_NUMBER    IN  NUMBER,
      P_INIT_MSG_LIST	      IN  VARCHAR2,
      P_COMMIT		      IN  VARCHAR2,
      P_VALIDATION_LEVEL      IN  NUMBER,
      P_ENTITY		      IN  VARCHAR2,
      P_LEAD_ID		      IN  NUMBER,
      P_CREATING_USERNAME     IN  VARCHAR2,
      P_ASSIGNMENT_TYPE	      IN  VARCHAR2,
      P_BYPASS_CM_OK_FLAG     IN  VARCHAR2,
      P_PROCESS_RULE_ID	      IN  NUMBER,
      X_RETURN_STATUS	      OUT NOCOPY VARCHAR2,
      X_MSG_COUNT	      OUT NOCOPY NUMBER,
      X_MSG_DATA	      OUT NOCOPY VARCHAR2 ) IS

      l_partner_count		  number := 1;
      l_partner_id		  number;
      l_rank			  number;
      l_source_type		  VARCHAR2(30);
      l_partner_id_tbl		  JTF_NUMBER_TABLE;
      l_rank_tbl		  JTF_NUMBER_TABLE;
      l_source_type_tbl		  JTF_VARCHAR2_TABLE_100;
      l_party_id		  number;
      l_party_count		  number := 0;

      cursor lc_get_saved_pts (pc_lead_id number) is
	 select	pvla.partner_id	partner_id, pvla.ASSIGN_SEQUENCE, pvla.source_type
	 from	pv_lead_assignments pvla
	where  pvla.lead_id = pc_lead_id
	and    pvla.status = 'UNASSIGNED';

      l_api_name	    CONSTANT VARCHAR2(30) := 'Create_Assignment';
      l_api_version_number  CONSTANT NUMBER	  := 1.0;

Begin
   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'In	' || l_api_name	|| '. Lead id: ' || p_lead_id);
      fnd_msg_pub.Add;
   END IF;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version_number,
				       p_api_version_number,
				       l_api_name,
				       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set	to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      fnd_msg_pub.initialize;
   END IF;

   l_PARTNER_ID_TBL    :=  JTF_NUMBER_TABLE();
   l_RANK_TBL	       :=  JTF_NUMBER_TABLE();
   l_source_type_tbl   :=  jtf_varchar2_table_100();
   x_return_status     :=  FND_API.G_RET_STS_SUCCESS ;

   open	lc_get_saved_pts(p_lead_id);
   loop
      fetch lc_get_saved_pts  into l_partner_id, l_rank, l_source_type;
      exit when	 lc_get_saved_pts%notfound;
      l_party_count := 0;
      IF l_partner_id_tbl.count > 0 THEN
          FOR x IN ( SELECT count(party_id) cnt
	               FROM   (SELECT rownum idx, column_value party_id
		                   FROM  (SELECT column_value
		                          FROM TABLE (CAST(l_partner_id_tbl AS JTF_NUMBER_TABLE))
                                  )
                          ) a
	               WHERE a.party_id = l_partner_id
                   GROUP BY A.PARTY_ID )
	   LOOP
	      l_party_count := x.cnt;
	   END LOOP;

      END IF;
      IF l_party_count = 0 THEN
          l_PARTNER_ID_TBL.extend;
          l_RANK_TBL.extend;
          l_source_type_tbl.extend;

          l_PARTNER_ID_TBL(l_partner_count)	:= l_partner_id;
          l_RANK_TBL(l_partner_count)		:= l_rank;
          l_source_type_tbl(l_partner_count)     := l_source_type;

          l_partner_count := l_partner_count + 1;
      END IF;
   end loop;
   close lc_get_saved_pts;

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'Deleting Rows from	pv_lead_assignments : ');
      fnd_msg_pub.Add;
   END IF;

   delete from pv_lead_assignments
   where lead_id = p_lead_id
   and	status = 'UNASSIGNED';

   PV_ASSIGNMENT_PUB. CREATEASSIGNMENT(
	 p_api_version_number	  => 1.0
	,p_init_msg_list	  => FND_API.G_FALSE
	,p_commit		  => FND_API.G_FALSE
	,p_validation_level	  => FND_API.G_VALID_LEVEL_FULL
	,p_entity		  => p_entity
	,p_lead_id		  => p_lead_id
	,P_creating_username	  => p_creating_username
	,P_assignment_type	  => p_assignment_type
	,p_bypass_cm_ok_flag	  => p_bypass_cm_ok_flag
	,p_partner_id_tbl	  => l_partner_id_tbl
	,p_rank_tbl		  => l_rank_tbl
	,p_partner_source_tbl	  => l_source_type_tbl
	,p_process_rule_id	  => p_process_rule_id
	,x_return_status	  => x_return_status
	,x_msg_count		  => x_msg_count
	,x_msg_data		  => x_msg_data);

   IF FND_API.To_Boolean ( p_commit )	THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if	count is 1, get	message	info.
   fnd_msg_pub.Count_And_Get( p_encoded	  =>  FND_API.G_FALSE,
	    p_count	=>  x_msg_count,
	    p_data	=>  x_msg_data);
EXCEPTION

   WHEN	FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR ;

      fnd_msg_pub.Count_And_Get( p_encoded   =>	 FND_API.G_FALSE,
	       p_count	   =>  x_msg_count,
				 p_data	     =>	 x_msg_data);

   WHEN	FND_API.G_EXC_UNEXPECTED_ERROR THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      fnd_msg_pub.Count_And_Get( p_encoded   =>	 FND_API.G_FALSE,
				 p_count     =>	 x_msg_count,
				 p_data	     =>	 x_msg_data);

   WHEN	OTHERS THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);

      fnd_msg_pub.Count_And_Get( p_encoded   =>	 FND_API.G_FALSE,
				 p_count     =>	 x_msg_count,
				 p_data	     =>	 x_msg_data);

End Create_Assignment;


-- pklin
--=============================================================================+
--|  Public Procedure							       |
--|									       |
--|    Debug								       |
--|									       |
--|  Parameters								       |
--|  IN									       |
--|  OUT								       |
--|									       |
--|									       |
--| NOTES:								       |
--|									       |
--| HISTORY								       |
--|									       |
--==============================================================================
PROCEDURE Debug(
   p_msg_string	      IN VARCHAR2
)
IS

BEGIN
      FND_MESSAGE.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      FND_MESSAGE.Set_Token('TEXT', p_msg_string);
      FND_MSG_PUB.Add;
END Debug;
-- =================================End	of Debug================================

--=============================================================================+
--|  Public Procedure							       |
--|									       |
--|    Set_Message							       |
--|									       |
--|  Parameters								       |
--|  IN									       |
--|  OUT NOCOPY 								       |
--|									       |
--|									       |
--| NOTES:								       |
--|									       |
--| HISTORY								       |
--|									       |
--==============================================================================
PROCEDURE Set_Message(
    p_msg_level	    IN	    NUMBER,
    p_msg_name	    IN	    VARCHAR2,
    p_token1	    IN	    VARCHAR2,
    p_token1_value  IN	    VARCHAR2,
    p_token2	    IN	    VARCHAR2 :=	NULL ,
    p_token2_value  IN	    VARCHAR2 :=	NULL,
    p_token3	    IN	    VARCHAR2 :=	NULL,
    p_token3_value  IN	    VARCHAR2 :=	NULL
)
IS
BEGIN
    IF FND_MSG_PUB.Check_Msg_Level(p_msg_level)	THEN
	FND_MESSAGE.Set_Name('PV', p_msg_name);
	FND_MESSAGE.Set_Token(p_token1,	p_token1_value);

	IF (p_token2 IS	NOT NULL) THEN
	   FND_MESSAGE.Set_Token(p_token2, p_token2_value);
	END IF;

	IF (p_token3 IS	NOT NULL) THEN
	   FND_MESSAGE.Set_Token(p_token3, p_token3_value);
	END IF;

	FND_MSG_PUB.Add;
    END	IF;
END Set_Message;
-- ==============================End of	Set_Message==============================

-- %%%%%%%%%%%%%%%%%%%%%%  Private Routines %%%%%%%%%%%%%%%%%%%%%%%
-- =================================================================
-- get_no_of_delimiter will return the no of delimiters	in a given
-- string.
-- When	p_attr_value is	"abc+++def+++ghi" and the delimiter is
-- "+++" then the output from this function would be 2
-- which means there are two delimiters	in this	function
-- =================================================================

FUNCTION get_no_of_delimiter
(
     p_attr_value IN VARCHAR2,
     p_delimiter IN VARCHAR2
)
RETURN NUMBER
IS
   return_value	NUMBER := NULL;
   temp_string VARCHAR2(3000);
   l_attr_value varchar2(2000);
BEGIN
-- The two strings are the same.

   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      debug('in get_no_of_delimiter *******************');
       --since fnd_msg_pub supports debiug message of length 1972
	 -- we are passing split of attribute value as it may exceed 2000 length
      l_attr_value := p_attr_value;
      while (l_attr_value is not null) loop
	debug('Attr Value(Multi line printed): '||substr( l_attr_value, 1, 1800 ));
	l_attr_value := substr( l_attr_value, 1801 );
      end loop;

      debug('Delimiter '||p_delimiter);
   END IF;


   IF p_attr_value = p_delimiter
   THEN
	  return_value := 1;
   ELSE
      temp_string := REPLACE (p_attr_value, p_delimiter);

      IF temp_string IS	NULL
      THEN
	 return_value := LENGTH	(p_attr_value) / LENGTH	(p_delimiter);
      ELSE
	 return_value := (LENGTH (p_attr_value)	- LENGTH (temp_string))/ LENGTH	(p_delimiter);
      END IF;
   END IF;
   RETURN return_value;
END;

-- ====================================== End of get_no_of_delimiter ==========================================

-- =============================================================================================================
-- Tokenize will break up a string seperated with delimiter into different entries and will insert into
-- PL/SQL table

-- Eg :
-- p_attr_value	is 1000+++2000 and delimiter is	+++
-- then	it will	be inserted as 1000, 2000 as two seperate entries into PL/SQL table
-- ===========================================================================================================


PROCEDURE tokenize
(
   p_attr_value	    IN	 VARCHAR2,
   p_delimiter	    IN	 VARCHAR2,
   p_attr_value_tbl OUT NOCOPY 	 JTF_VARCHAR2_TABLE_4000
)
 IS

  l_token	VARCHAR2(4000);
  l_ctr		PLS_INTEGER := 1;
  l_delm_leng	NUMBER;


BEGIN
   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      debug('p_attr_value '||p_attr_value);
      debug('p_delimiter '||p_delimiter);
   END IF;

   l_delm_leng := length(p_delimiter);

   p_attr_value_tbl := JTF_VARCHAR2_TABLE_4000();

   FOR i IN 1..LENGTH(p_attr_value)
   LOOP

     IF	SUBSTR(p_attr_value,i,l_delm_leng) = p_delimiter THEN


	   p_attr_value_tbl.extend;
	   p_attr_value_tbl(l_ctr) := l_token;
	   l_ctr := l_ctr + 1;
	   l_token := NULL;

     ELSIF i = LENGTH(p_attr_value) THEN


	   p_attr_value_tbl.extend;
	   l_token := l_token || SUBSTR(p_attr_value,i,1);

	   p_attr_value_tbl(l_ctr) := l_token;
	   l_ctr := l_ctr + 1;
	   l_token := NULL;

     ELSE

	  l_token := l_token ||	SUBSTR(p_attr_value,i,1);

	  IF p_delimiter LIKE l_token ||'%' THEN
	      l_token := null;
	  END IF;

    END	IF;

  end loop;


  for i	in 1 ..	p_attr_value_tbl.count
  loop
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
	 debug('tokens '||	p_attr_value_tbl(i));
      END IF;
  end loop;

END;


-- ====================================== End of tokenize ==========================================

end PV_MATCH_V2_PUB;

/
