--------------------------------------------------------
--  DDL for Package Body OKC_PRICE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_PRICE_PUB" AS
/* $Header: OKCPPREB.pls 120.0 2005/05/26 09:41:21 appldev noship $ */
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

G_NO_PRICING_RULE   Varchar2(1) := 'N';  -- No Pricing Rule attached
G_NO_PRICE_LIST     Varchar2(1) := 'E';  -- Pricing Rule attached but no Price List
G_NO_LOV_PRICE_LIST Varchar2(1) := 'V';  -- Pricing Rule attached but NO LOV Price
                                         -- List found, possible for Buy Contracts
G_OK_PRICE_LIST     Varchar2(1) := 'S';  -- Price List Found

---smhanda added ---------------------------------------------------------------------
--------------------------------------------------------------------
--FUNCTION - GET_LSE_SOURCE_VALUE
-- This function is used in mapping of attributes between QP and OKC
-- The calls to this function will be made by QP Engine to get values for
--various Qualifiers and Pricing Attributes
-- p_lse_tbl - Global Table holding various OKX_SOURCES and their values for lse
-- p_registered_source - The source for which value should be returned
-- Returns the value for the p_registered_source
----------------------------------------------------------------------------
FUNCTION Get_LSE_SOURCE_VALUE (
            p_lse_tbl         IN      global_lse_tbl_type,
            p_registered_source  IN      VARCHAR2)
RETURN VARCHAR2 IS
BEGIN
    return OKC_PRICE_PVT.Get_LSE_SOURCE_VALUE (
            p_lse_tbl         => p_lse_tbl,
            p_registered_source  => p_registered_source);
END Get_LSE_SOURCE_VALUE;

-----------------------------------------------------------------------------
--FUNCTION - GET_RUL_SOURCE_VALUE
-- This function is used in mapping of attributes between QP and OKC
-- The calls to this function will be made by QP Engine to get values for
--various Qualifiers and Pricing Attributes
-- p_rul_tbl - Global Table holding various OKX_SOURCES and their values for rules
-- p_registered_code - The rule code for which value should be returned
-- p_registered_source - The source for which value should be returned
-- Returns the value for the p_registered_source+p_registered_code
----------------------------------------------------------------------------
FUNCTION Get_RUL_SOURCE_VALUE (
            p_rul_tbl            IN      global_rprle_tbl_type,
            p_registered_code    IN      varchar2,
            p_registered_source  IN      VARCHAR2)
RETURN VARCHAR2 IS
BEGIN
    return OKC_PRICE_PVT.Get_RUL_SOURCE_VALUE (
            p_rul_tbl            => p_rul_tbl,
            p_registered_code    => p_registered_code,
            p_registered_source  => p_registered_source);
END Get_RUL_SOURCE_VALUE;


------------------------------------------------------------------------------
--FUNCTION - GET_PRLE_SOURCE_VALUE
-- This function is used in mapping of attributes between QP and OKC
-- The calls to this function will be made by QP Engine to get values for
--various Qualifiers and Pricing Attributes
-- p_prle_tbl - Global Table holding various OKX_SOURCES and their values for rules
-- p_registered_role - The role code for which value should be returned
-- p_registered_source - The source for which value should be returned
-- Returns the value for the p_registered_source+p_registered_role
----------------------------------------------------------------------------
FUNCTION Get_PRLE_SOURCE_VALUE (
            p_prle_tbl          IN      global_rprle_tbl_type,
            p_registered_code   IN      varchar2,
            p_registered_source IN      VARCHAR2)
RETURN VARCHAR2 IS
BEGIN
   return  OKC_PRICE_PVT.Get_PRLE_SOURCE_VALUE(
            p_prle_tbl            => p_prle_tbl,
            p_registered_code    => p_registered_code,
            p_registered_source  => p_registered_source);
END Get_PRLE_SOURCE_VALUE;

------------------------------------------------------------------------------
--FUNCTION - ROUND_PRICE
-- This function is used to round the price (parameter p_price) according to rules
-- of currency (p_cur_code - currency code)
----------------------------------------------------------------------------
FUNCTION ROUND_PRICE(p_price NUMBER, p_cur_code VARCHAR2) RETURN NUMBER IS
    l_price NUMBER := p_price;
    Cursor fnd_cur IS
           SELECT Minimum_Accountable_Unit,
                  Precision,
                  Extended_Precision
           FROM FND_CURRENCIES
           WHERE Currency_Code = p_cur_code ;
    l_mau FND_CURRENCIES.MINIMUM_ACCOUNTABLE_UNIT%TYPE;
    l_sp  FND_CURRENCIES.PRECISION%TYPE;
    l_ep  FND_CURRENCIES.EXTENDED_PRECISION%TYPE;
  BEGIN
    open fnd_cur;
    fetch fnd_cur into l_mau,l_sp,l_ep;
    close fnd_cur;

    If (l_mau is not null) Then
       If (l_mau < 0.00001) Then
          return ( round(l_price,5) );
       Else
          return ( round(l_price/l_mau) * l_mau );
       End If;
    Elsif l_sp is not null then
       If (l_sp > 5) Then
          return ( round(l_price,5) );
       Else
          return ( round(l_price, l_sp) );
       End If;
    Else
       return ( round(l_price,5) );
    End If;
 EXCEPTION
    WHEN NO_DATA_FOUND THEN
         return l_price;
    WHEN OTHERS THEN
         return l_price;
END ROUND_PRICE;


   ----------------------------------------------------------------------------
-- CALCULATE_PRICE
-- This procedure will calculate the price for the sent in line/header
-- px_cle_price_tbl returns the priced line ids and thier prices
-- p_level tells whether line level or header level
-- possible value 'L','H','QA' DEFAULT 'L'
--p_calc_flag   'B'(Both -calculate and search),'C'(Calculate Only), 'S' (Search only)
----------------------------------------------------------------------------
PROCEDURE CALCULATE_price(
          p_api_version                 IN          NUMBER ,
          p_init_msg_list               IN          VARCHAR2 ,
          p_CHR_ID                      IN          NUMBER,
          p_Control_Rec			        IN          OKC_CONTROL_REC_TYPE,
          px_req_line_tbl               IN  OUT NOCOPY   QP_PREQ_GRP.LINE_TBL_TYPE,
          px_Req_qual_tbl               IN  OUT NOCOPY   QP_PREQ_GRP.QUAL_TBL_TYPE,
          px_Req_line_attr_tbl          IN  OUT NOCOPY   QP_PREQ_GRP.LINE_ATTR_TBL_TYPE,
          px_Req_LINE_DETAIL_tbl        IN  OUT NOCOPY   QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE,
          px_Req_LINE_DETAIL_qual_tbl   IN  OUT NOCOPY   QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE,
          px_Req_LINE_DETAIL_attr_tbl   IN  OUT NOCOPY   QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE,
          px_Req_RELATED_LINE_TBL       IN  OUT NOCOPY   QP_PREQ_GRP.RELATED_LINES_TBL_TYPE,
          px_CLE_PRICE_TBL		        IN  OUT NOCOPY   CLE_PRICE_TBL_TYPE,
          x_return_status               OUT  NOCOPY VARCHAR2,
          x_msg_count             OUT  NOCOPY NUMBER,
          x_msg_data              OUT  NOCOPY VARCHAR2) IS
    BEGIN
          OKC_PRICE_PVT.CALCULATE_price(
          p_api_version                 =>  p_api_version,
          p_init_msg_list               =>  p_init_msg_list ,
          p_CHR_ID                      =>  p_CHR_ID,
          p_Control_Rec			        =>  p_Control_Rec,
          px_req_line_tbl               =>  px_req_line_tbl,
          px_Req_qual_tbl               =>  px_Req_qual_tbl,
          px_Req_line_attr_tbl          =>  px_Req_line_attr_tbl,
          px_Req_LINE_DETAIL_tbl        =>  px_Req_LINE_DETAIL_tbl,
          px_Req_LINE_DETAIL_qual_tbl   =>  px_Req_LINE_DETAIL_qual_tbl,
          px_Req_LINE_DETAIL_attr_tbl   =>  px_Req_LINE_DETAIL_attr_tbl,
          px_Req_RELATED_LINE_TBL       =>  px_Req_RELATED_LINE_TBL,
          px_CLE_PRICE_TBL		        =>  px_CLE_PRICE_TBL,
          x_return_status               =>  x_return_status,
          x_msg_count                   =>  x_msg_count,
          x_msg_data                    =>  x_msg_data);
    END CALCULATE_PRICE;

--------------------------------------------------------------------------
-- Update_Contract_price
-- This procedure will calculate the price for all the Priced lines in a contract
-- while calculating whether header level adjustments are to be considrerd
-- or not will be taken care of by px_control_rec.p_level (possible values 'L','H','QA')
-- 'L' line only, 'H' Header and all the lines ,'QA' QA only
-- p_chr_id - id of the header
-- x_chr_net_price - estimated amount on header
----------------------------------------------------------------------------
PROCEDURE Update_CONTRACT_price(
          p_api_version                 IN          NUMBER,
          p_init_msg_list               IN          VARCHAR2 ,
          p_commit                      IN          VARCHAR2 ,
          p_CHR_ID                      IN          NUMBER,
          px_Control_Rec			    IN  OUT NOCOPY     PRICE_CONTROL_REC_TYPE,
          x_CLE_PRICE_TBL		        OUT  NOCOPY CLE_PRICE_TBL_TYPE,
          x_chr_net_price               OUT  NOCOPY NUMBER,
          x_return_status               OUT  NOCOPY VARCHAR2,
          x_msg_count                   OUT  NOCOPY NUMBER,
          x_msg_data                    OUT  NOCOPY VARCHAR2) IS

          l_control_rec                  OKC_CONTROL_REC_TYPE;
    BEGIN

          l_control_rec.p_Request_Type_Code	   := px_Control_Rec.p_Request_Type_Code;
          l_control_rec.p_negotiated_changed   := px_Control_Rec.p_negotiated_changed;
          l_control_rec.p_level                := px_Control_Rec.p_level ;
          l_control_rec.p_calc_flag            := px_Control_Rec.p_calc_flag  ;
          l_control_rec.p_config_yn            := px_Control_Rec.p_config_yn;
          l_control_rec.p_top_model_id         := px_Control_Rec.p_top_model_id;

         OKC_PRICE_PVT.Update_CONTRACT_price(
          p_api_version                 =>  p_api_version,
          p_init_msg_list               =>  p_init_msg_list,
          p_commit                      =>  p_commit,
          p_CHR_ID                      =>  p_CHR_ID,
          px_Control_Rec			    =>  l_Control_Rec,
          x_CLE_PRICE_TBL		        =>  x_CLE_PRICE_TBL,
          x_chr_net_price               =>  x_chr_net_price,
          x_return_status               =>  x_return_status,
          x_msg_count                   =>  x_msg_count,
          x_msg_data                    =>  x_msg_data);
    END UPDATE_CONTRACT_PRICE;

----------------------------------------------------------------------------
-- Update_Line_price
-- This procedure will calculate the price for all the Priced lines below sent in line
-- Called when a line is updated in the form
-- p_cle_id - id of the line updated
-- p_chr_id - id of the header
-- p_lowest_level Possible values 0(p_cle_id not null and this line is subline),
--                                 1(p_cle_id not null and this line is upper line),
--                                 -1(update all lines)
--                                 -2(update all lines and header)
--                                 DEFAULT -2
--
--px_chr_list_price  IN OUT -holds the total line list price, for right value pass in the existing value,
--px_chr_net_price   IN OUT -holds the total line net price, for right value pass in the existing value


----------------------------------------------------------------------------
PROCEDURE Update_LINE_price(
          p_api_version                 IN          NUMBER,
          p_init_msg_list               IN          VARCHAR2 ,
          p_commit                      IN          VARCHAR2 ,
          p_CHR_ID                      IN          NUMBER,
          p_cle_id			            IN	        NUMBER ,
          p_lowest_level                IN          NUMBER ,
          px_Control_Rec			    IN   OUT NOCOPY    PRICE_CONTROL_REC_TYPE,
          px_chr_list_price             IN   OUT NOCOPY    NUMBER,
          px_chr_net_price              IN   OUT NOCOPY    NUMBER,
          x_CLE_PRICE_TBL		        OUT  NOCOPY CLE_PRICE_TBL_TYPE,
          px_cle_amt    		        IN   OUT NOCOPY    NUMBER,
          x_return_status               OUT  NOCOPY VARCHAR2,
          x_msg_count                   OUT  NOCOPY NUMBER,
          x_msg_data                    OUT  NOCOPY VARCHAR2)IS

          l_control_rec                  OKC_CONTROL_REC_TYPE;
    BEGIN

          l_control_rec.p_Request_Type_Code	   := px_Control_Rec.p_Request_Type_Code;
          l_control_rec.p_negotiated_changed   := px_Control_Rec.p_negotiated_changed;
          l_control_rec.p_level                := px_Control_Rec.p_level ;
          l_control_rec.p_calc_flag            := px_Control_Rec.p_calc_flag  ;
          l_control_rec.p_config_yn            := px_Control_Rec.p_config_yn;
          l_control_rec.p_top_model_id         := px_Control_Rec.p_top_model_id;

        OKC_PRICE_PVT.Update_LINE_price(
          p_api_version                 =>          p_api_version,
          p_init_msg_list               =>         p_init_msg_list,
          p_commit                      =>         p_commit,
          p_CHR_ID                      =>          p_CHR_ID,
          p_cle_id			            =>	        p_cle_id,
          p_lowest_level                =>          p_lowest_level,
          px_Control_Rec			    =>          l_Control_Rec,
          px_chr_list_price             =>          px_chr_list_price,
          px_chr_net_price              =>          px_chr_net_price,
          x_CLE_PRICE_TBL		        =>          x_CLE_PRICE_TBL,
          px_cle_amt    		        =>          px_cle_amt,
          x_return_status               =>          x_return_status,
          x_msg_count                   =>          x_msg_count,
          x_msg_data                    =>          x_msg_data);
     END UPDATE_LINE_PRICE;

----------------------------------------------------------------------------
-- GET_MANUAL_ADJUSTMENTS
-- This procedure will return all the manual adjustments that qualify for the
-- sent in lines and header
-- To get adjustments for a line pass p_cle_id and p_control_rec.p_level='L'
-- To get adjustments for a Header pass p_cle_id as null and p_control_rec.p_level='H'
----------------------------------------------------------------------------
PROCEDURE get_manual_adjustments(
          p_api_version                 IN          NUMBER,
          p_init_msg_list               IN          VARCHAR2 ,
          p_CHR_ID                      IN          NUMBER,
          p_cle_id                      IN          number                     ,
          p_Control_Rec			        IN          PRICE_CONTROL_REC_TYPE,
          x_ADJ_tbl                     OUT  NOCOPY MANUAL_Adj_Tbl_Type,
          x_return_status               OUT  NOCOPY VARCHAR2,
          x_msg_count                   OUT  NOCOPY NUMBER,
          x_msg_data                    OUT  NOCOPY VARCHAR2) IS

          l_control_rec                  OKC_CONTROL_REC_TYPE;
    BEGIN

          l_control_rec.p_Request_Type_Code	   := p_Control_Rec.p_Request_Type_Code;
          l_control_rec.p_negotiated_changed   := p_Control_Rec.p_negotiated_changed;
          l_control_rec.p_level                := p_Control_Rec.p_level ;
          l_control_rec.p_calc_flag            := p_Control_Rec.p_calc_flag  ;
          l_control_rec.p_config_yn            := p_Control_Rec.p_config_yn;
          l_control_rec.p_top_model_id         := p_Control_Rec.p_top_model_id;

        OKC_PRICE_PVT.get_manual_adjustments(
          p_api_version                 =>          p_api_version,
          p_init_msg_list               =>          p_init_msg_list,
          p_CHR_ID                      =>            p_CHR_ID,
          p_cle_id                      =>            p_cle_id,
          p_Control_Rec			        =>            l_Control_Rec,
          x_ADJ_tbl                     =>   x_ADJ_tbl,
          x_return_status               =>    x_return_status,
          x_msg_count                   =>    x_msg_count,
          x_msg_data                    =>   x_msg_data);
      END GET_MANUAL_ADJUSTMENTS;
---end smhanda added------------------------------------------------------------------

Function Get_Line_Rule(p_cle_id        Number,
                       p_category      Varchar2,
                       p_object_code   Varchar2)
  Return Varchar2 IS
  cursor c1 Is
  select rul.object1_id1
    from okc_rules_b rul,
         okc_rule_groups_b rgp
   where rul.rgp_id = rgp.id
     and rul.rule_information_category = p_category
     and rul.jtot_object1_code = p_object_code
     and rgp.cle_id = p_cle_id;
  l_object_id okc_rules_b.object1_id1%TYPE;
BEGIN
  -- dbms_output.put_line('Get_Line_Rule');
  Open c1;
  Fetch c1 Into l_object_id;
  If c1%notfound Then
    l_object_id := Null;
  End If;
  Close c1;
  return(l_object_id);
END Get_Line_Rule;

Function Get_Line_Pricing_Rule(p_cle_id        Number,
                               p_category      Varchar2,
                               x_return_status OUT NOCOPY Varchar2)
  Return Varchar2 IS
  cursor c1 Is
  select rul.object1_id1,
	    rul.jtot_object1_code
    from okc_rules_b rul,
         okc_rule_groups_b rgp
   where rul.rgp_id = rgp.id
     and rul.rule_information_category = p_category
     and rgp.cle_id = p_cle_id;
  l_object_id okc_rules_b.object1_id1%TYPE;
  l_jtot_object okc_rules_b.jtot_object1_code%TYPE;
  l_row_notfound Boolean;
BEGIN
  -- dbms_output.put_line('Get_Line_Pricing_Rule');
  Open c1;
  Fetch c1 Into l_object_id, l_jtot_object;
  l_row_notfound := c1%NotFound;
  Close c1;
  If l_row_notfound Then
    x_return_status := G_NO_PRICING_RULE;
  Elsif l_jtot_object = G_JTF_NOLOV Then
    x_return_status := G_NO_LOV_PRICE_LIST;
  Elsif l_object_id Is Null Then
    x_return_status := G_NO_PRICE_LIST;
  Else
    x_return_status := G_OK_PRICE_LIST;
  End If;
  return(l_object_id);
END Get_Line_Pricing_Rule;

Function Get_Hdr_Rule(p_chr_id      NUMBER,
                      p_category    VARCHAR2,
                      p_object_code VARCHAR2)
  Return Varchar2 Is
  cursor c1 Is
  select rul.object1_id1
    from okc_rules_b rul,
         okc_rule_groups_b rgp
   where rul.rgp_id = rgp.id
     and rul.rule_information_category = p_category
     and rul.jtot_object1_code = p_object_code
     and rgp.chr_id = p_chr_id;
  l_object_id okc_rules_b.object1_id1%TYPE;
  l_jtot_object okc_rules_b.jtot_object1_code%TYPE;
BEGIN
  -- dbms_output.put_line('Get_Hdr_Rule');
  Open c1;
  Fetch c1 Into l_object_id;
  If c1%notfound Then
    l_object_id := Null;
  End If;
  Close c1;
  return(l_object_id);
END Get_Hdr_Rule;

Function Get_Hdr_Pricing_Rule(p_chr_id        NUMBER,
                              p_category      VARCHAR2,
                              x_return_status OUT NOCOPY Varchar2)
  Return Varchar2 Is
  cursor c1 Is
  select rul.object1_id1,
	    rul.jtot_object1_code
    from okc_rules_b rul,
         okc_rule_groups_b rgp
   where rul.rgp_id = rgp.id
     and rul.rule_information_category = p_category
     and rgp.chr_id = p_chr_id;
  l_object_id okc_rules_b.object1_id1%TYPE;
  l_jtot_object okc_rules_b.jtot_object1_code%TYPE;
  l_row_notfound Boolean;
BEGIN
  -- dbms_output.put_line('Get_Hdr_Pricing_Rule');
  Open c1;
  Fetch c1 Into l_object_id, l_jtot_object;
  l_row_notfound := c1%NotFound;
  Close c1;
  If l_row_notfound Then
    x_return_status := G_NO_PRICING_RULE;
  Elsif l_jtot_object = G_JTF_NOLOV Then
    x_return_status := G_NO_LOV_PRICE_LIST;
  Elsif l_object_id Is Null Then
    x_return_status := G_NO_PRICE_LIST;
  Else
    x_return_status := G_OK_PRICE_LIST;
  End If;
  return(l_object_id);
END Get_Hdr_Pricing_Rule;

--2782972
---Modified cursor c1 to check for shared mode,Full install not required to call pricing engine

Function Product_Installed(p_product_name Varchar2)
  Return Boolean IS
  l_row_notfound Boolean := True;
  l_dummy Varchar2(1);
  l_return_status Boolean := True;
  cursor c1(p_status Varchar2,p_status1 Varchar2) is
  select 'x'
    from fnd_application app,
         fnd_product_installations prd
   where app.application_short_name = p_product_name
     and app.application_id = prd.application_id
	 and prd.status in(p_status,p_status1);

Begin
  -- dbms_output.put_line('Product_Installed');
  Open c1('I','S');
  Fetch c1 Into l_dummy;
  l_row_notfound := c1%NotFound;
  Close c1;
  If l_row_notfound Then
    OKC_API.set_message(G_APP_NAME, 'OKC_QP_NOT_INSTALLED');
    l_return_status := False;
  End If;
  Return (l_return_status);
End Product_Installed;
--
Procedure Get_Price_List(p_clev_tbl OKC_CONTRACT_PUB.clev_tbl_type,
                         x_price_list OUT NOCOPY Varchar2,
                         x_return_status OUT NOCOPY Varchar2) Is
  l_row_notfound Boolean := True;
  l_price_list Varchar2(30);
  l_cle_id Number;
  l_cle_id_ascendant Number;
  l_chr_id Number;
  l_return_status Varchar2(1);
  Ok_Price_List Exception;
  No_Price_List Exception;
  No_Lov_Price_List Exception;
  No_Pricing_Rule Exception;
  invalid_line Exception;
  cursor c1(p_cle_id Number) is
  select cle_id_ascendant
    from okc_ancestrys_v
   where cle_id = p_cle_id
   order by level_sequence desc;
  cursor c2(p_cle_id Number) is
  select dnz_chr_id
    from okc_k_lines_b
   where id = p_cle_id;
Begin
  -- dbms_output.put_line('Get_Price_List');
  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  If p_clev_tbl(1).id Is Null Or
     p_clev_tbl(1).id = OKC_API.G_MISS_NUM Then
    If p_clev_tbl(1).cle_id Is Null Or
       p_clev_tbl(1).cle_id = OKC_API.G_MISS_NUM Then
      l_cle_id := Null;
    Else
      l_cle_id := p_clev_tbl(1).cle_id;
    End If;
  Else
    l_cle_id := p_clev_tbl(1).id;
  End If;
  If l_cle_id Is Not Null Then
    l_price_list := Get_Line_Pricing_Rule(l_cle_id, G_PRE_RULE, l_return_status);
    -- If Price List found in the Pricing Rule, return with success
    -- If NO LOV Price List found, return with success
    -- If No Price List found in the attached rule, return with Error
    -- If No Pricing Rule found, search at the higher level; If found none, return with Success
    If l_return_status = G_OK_PRICE_LIST Then
	 Raise Ok_Price_List;
    Elsif l_return_status = G_NO_LOV_PRICE_LIST Then
	 Raise No_Lov_Price_List;
    Elsif l_return_status = G_NO_PRICE_LIST Then
	 Raise No_Price_List;
    End If;
    Open c1(l_cle_id);
    Loop
      Fetch c1 Into l_cle_id_ascendant;
      Exit When c1%NotFound;
      l_price_list := Get_Line_Pricing_Rule(l_cle_id_ascendant, G_PRE_RULE, l_return_status);
      If l_return_status = G_OK_PRICE_LIST Then
	   Raise Ok_Price_List;
      Elsif l_return_status = G_NO_LOV_PRICE_LIST Then
  	   Raise No_Lov_Price_List;
      Elsif l_return_status = G_NO_PRICE_LIST Then
  	   Raise No_Price_List;
      End If;
    End Loop;
    Close c1;
  End If;
  If p_clev_tbl(1).dnz_chr_id Is Null Or
     p_clev_tbl(1).dnz_chr_id = OKC_API.G_MISS_NUM Then
    If l_cle_id Is Not Null Then
      Open c2(l_cle_id);
      Fetch c2 Into l_chr_id;
      l_row_notfound := c2%NotFound;
      Close c2;
      If l_row_notfound Then
        Raise Invalid_Line;
      End If;
    Else
      Raise Invalid_Line;
    End If;
  Else
    l_chr_id := p_clev_tbl(1).dnz_chr_id;
  End If;
  l_price_list := Get_Hdr_Pricing_Rule(l_chr_id, G_PRE_RULE, l_return_status);
  If l_return_status = G_OK_PRICE_LIST Then
    Raise Ok_Price_List;
  Elsif l_return_status = G_NO_LOV_PRICE_LIST Then
    Raise No_Lov_Price_List;
  Elsif l_return_status = G_NO_PRICE_LIST Then
    Raise No_Price_List;
  End If;
  Raise No_Pricing_Rule;
Exception
  When No_Pricing_Rule Then
    x_price_list := Null;
  When No_Lov_Price_List Then
    x_price_list := Null;
  When No_Price_List Then
    OKC_API.set_message(G_APP_NAME, 'OKC_PRICE_LIST_NOT_FOUND');
    x_return_status := OKC_API.G_RET_STS_ERROR;
  When OK_Price_List Then
    If c1%IsOpen Then
      Close c1;
    End If;
    x_price_list := l_price_list;
  When Invalid_Line Then
    OKC_API.set_message(G_APP_NAME, 'OKC_CONTRACT_NOT_FOUND');
    x_return_status := OKC_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    If c1%IsOpen Then
      Close c1;
    End If;
    If c2%IsOpen Then
      Close c2;
    End If;
    OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR, G_SQLCODE_TOKEN,
                        SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
End Get_Price_List;
--
Procedure Get_Inventory_Item(p_clev_tbl OKC_CONTRACT_PUB.clev_tbl_type,
                             p_cimv_tbl OKC_CONTRACT_ITEM_PUB.cimv_tbl_type,
                             x_inventory_item_id OUT NOCOPY Number,
                             x_uom_code OUT NOCOPY Varchar2,
                             x_qty OUT NOCOPY Number,
                             x_return_status OUT NOCOPY Varchar2) Is
  cursor c1(p_cle_id Number) is
  select object1_id1,
         uom_code,
         number_of_items
    from okc_k_items_v
   where cle_id = p_cle_id
     and priced_item_yn = 'Y';
     -- and jtot_object1_code in (G_JTF_usage,G_JTF_service);
  l_row_notfound Boolean := True;
  Inv_Item_Not_Found Exception;
  Item_Uom_Qty_Null Exception;
BEGIN
  -- dbms_output.put_line('Get_Inventory_Item');
  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  If Nvl(p_cimv_tbl(1).priced_item_yn, 'N') = 'Y' Then
    x_inventory_item_id := p_cimv_tbl(1).object1_id1;
    x_uom_code := p_cimv_tbl(1).uom_code;
    x_qty := p_cimv_tbl(1).number_of_items;
  Elsif p_clev_tbl(1).id Is Null Or
        p_clev_tbl(1).id = OKC_API.G_MISS_NUM Then
    Raise Inv_Item_Not_Found;
  Else
    Open c1(p_clev_tbl(1).id);
    Fetch c1
     Into x_inventory_item_id,
          x_uom_code,
          x_qty;
    l_row_notfound := c1%NotFound;
    Close c1;
    If l_row_notfound Then
      Raise Inv_Item_Not_Found;
    End If;
  End If;
  If x_inventory_item_id Is Null Or
     x_uom_code Is Null Or
     x_qty Is Null Then
    Raise Item_Uom_Qty_Null;
  End If;
EXCEPTION
  When Inv_Item_Not_Found Then
    x_return_status := OKC_API.G_RET_STS_ERROR;
    OKC_API.set_message(G_APP_NAME, 'OKC_INV_ITEM_NOT_FOUND');
  When Item_Uom_Qty_Null Then
    x_return_status := OKC_API.G_RET_STS_ERROR;
    OKC_API.set_message(G_APP_NAME, 'OKC_ITEM_UOM_QTY_NULL');
  WHEN OTHERS THEN
    If c1%IsOpen Then
      Close c1;
    End If;
    OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR, G_SQLCODE_TOKEN,
                        SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
END Get_Inventory_Item;
--
Procedure Get_Currency_Code(p_clev_tbl OKC_CONTRACT_PUB.clev_tbl_type,
                            x_cur_code OUT NOCOPY Varchar2,
                            x_return_status OUT NOCOPY Varchar2) Is
  cursor c1(p_chr_id Number) is
  select currency_code
    from okc_k_headers_b
   where id = p_chr_id;
  cursor c2(p_cle_id Number) is
  select k.currency_code
    from okc_k_headers_b k,
         okc_k_lines_b b
   where b.id = p_cle_id
     and k.id = b.dnz_chr_id;
  l_cle_id Number;
  l_row_notfound Boolean := True;
  Contract_Not_Found Exception;
BEGIN
  -- dbms_output.put_line('Get_Currency_Code');
  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  If p_clev_tbl(1).currency_code Is Null Or
     p_clev_tbl(1).currency_code = OKC_API.G_MISS_CHAR Then
    If p_clev_tbl(1).dnz_chr_id Is Null Or
       p_clev_tbl(1).dnz_chr_id = OKC_API.G_MISS_NUM Then
      If p_clev_tbl(1).id Is Null Or
         p_clev_tbl(1).id = OKC_API.G_MISS_NUM Then
        If p_clev_tbl(1).cle_id Is Null Or
           p_clev_tbl(1).cle_id = OKC_API.G_MISS_NUM Then
          Raise Contract_Not_Found;
        Else
          l_cle_id := p_clev_tbl(1).cle_id;
        End If;
      Else
        l_cle_id := p_clev_tbl(1).id;
      End If;
      Open c2(l_cle_id);
      Fetch c2
       Into x_cur_code;
      l_row_notfound := c1%NotFound;
      Close c2;
      If l_row_notfound Then
        Raise Contract_Not_Found;
      End If;
    Else
      Open c1(p_clev_tbl(1).dnz_chr_id);
      Fetch c1
       Into x_cur_code;
      l_row_notfound := c1%NotFound;
      Close c1;
      If l_row_notfound Then
        Raise Contract_Not_Found;
      End If;
    End If;
  Else
    x_cur_code := p_clev_tbl(1).currency_code;
  End If;
EXCEPTION
  When Contract_Not_Found Then
    x_return_status := OKC_API.G_RET_STS_ERROR;
    OKC_API.set_message(G_APP_NAME, 'OKC_CONTRACT_NOT_FOUND');
  WHEN OTHERS THEN
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR, G_SQLCODE_TOKEN,
                        SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
END Get_Currency_Code;
--
Procedure  BUILD_OKC_KLINE_REC
(
 p_contract_line_id  IN NUMBER,
 x_contract_line_rec  OUT NOCOPY OKC_PRICE_PUB.G_LINE_REC_TYPE,
 x_return_status   OUT NOCOPY VARCHAR2
)
Is
 Cursor Get_Line_det_Csr  Is
        Select  dnz_chr_id
         ,Start_date
         ,End_Date
         ,sts_code
        From   OKC_K_LINES_B
         Where  Id = p_contract_line_id;

 Cursor Get_Hdr_det_Csr (p_hdr_id Number) Is
        Select  Currency_code
               ,Cust_po_number
           ,scs_code
        From    OKC_K_HEADERS_B
        Where   id = p_hdr_id;

 Cursor Get_agreement_Csr(p_id Number) Is
        Select   Isa_Agreement_id
        From     OKC_GOVERNANCES_V
        Where  dnz_chr_id =  p_id
	   AND    cle_id IS NULL;
-- Changed Because it gives full table scan as it dont have a Index on Chr_Id.--Jomy
--        Where    chr_id = p_id;

/*** Item Csr - may not work for OKC Use Get_inventory_Item ***/
 Cursor Get_Item_Csr Is
        Select   Object1_id1
        From     OKC_K_ITEMS_V
        Where    cle_id = p_contract_line_id
        And      Jtot_object1_code in(G_JTF_usage,G_JTF_service);

/*** Get it in the above API for inv item ***/
 Cursor Get_usage_flag_Csr(l_id Number) Is
 Select Usage_item_flag
 From   OKX_SYSTEM_ITEMS_V
 Where  id1 = l_id ;

/**** Party Csr - Assumes a header party, we might have line too ***/
 Cursor Get_party_Csr (p_Kid Number) Is
 Select   object1_id1
 From     OKC_K_PARTY_ROLES_B
 Where    dnz_chr_id = p_kid
 And     Jtot_Object1_code = G_JTF_PARTY;

/*** Rule Csr - Assumes line level rule ?? ***/
 Cursor Get_rule_Csr(l_cat varchar2) Is
 Select   OBJECT1_ID1,
               RULE_INFORMATION1,
               RULE_INFORMATION2,
               RULE_INFORMATION3,
               RULE_INFORMATION4
 From     OKC_RULE_GROUPS_B  RG
  ,OKC_RULES_B        RL
 Where    RG.CLE_ID = p_contract_line_id
 AND      RG.ID     = RL.RGP_ID
 AND      RULE_INFORMATION_CATEGORY = l_cat;

 Cursor Get_Cust_Csr(p_bill_to_id Number, p_party_id number) Is
               Select    c.id1
  from OKX_CUST_SITE_USES_V a, okx_customer_accounts_v c
  where a.party_id = p_party_id and
   c.id1 = a.CUST_ACCOUNT_ID  and
   a.Id1 = p_bill_to_id And  a.Name = 'BILL_TO';


 P_name              Varchar2(40);
 l_chrid             Number;
 l_service_period    Varchar2(10);
 l_Service_duration  Number;
 l_return_status     Varchar2(10) := OKC_API.G_RET_STS_SUCCESS;
 l_agreement_id      Number;
 l_Cust_Acct_id      Number;
 l_item_id           Varchar2(40);
 l_party_id          Number;
 l_bill_id           Varchar2(240);
 l_bill_interval     Varchar2(240);
 lId                 Number;

      l_rule_rec          GET_RULE_CSR%ROWTYPE;

BEGIN
     x_return_status   :=  OKC_API.G_RET_STS_SUCCESS;

 X_Contract_line_rec.line_id:= p_contract_line_id;
 OPEN Get_line_det_csr;
 FETCH Get_Line_det_csr INTO
   x_Contract_line_rec.hdr_id,
   x_Contract_line_rec.start_date,
   x_Contract_line_rec.end_date,
   x_Contract_line_rec.status_code;
 CLOSE get_line_det_csr;

 OPEN Get_agreement_Csr(X_Contract_line_rec.hdr_id);
 FETCH Get_agreement_Csr INTO  x_contract_line_rec.agreement_id;
 CLOSE Get_agreement_Csr;

/*** Item csr not needed ****/
 OPEN Get_item_Csr;
 FETCH Get_item_Csr INTO  x_contract_line_rec.inventory_item_id;
 CLOSE Get_item_Csr;

/*** We can get this info from the get_inventory_item api ***/
 OPEN Get_usage_flag_Csr(x_contract_line_rec.inventory_item_id);
 FETCH Get_usage_flag_csr INTO x_Contract_line_rec.usage_item_flag;
 CLOSE Get_usage_flag_Csr;

/*** Do we need this ?? ***/
 OPEN Get_Party_Csr(X_Contract_line_rec.hdr_id );
 FETCH Get_Party_Csr INTO  x_contract_line_rec.party_id;
 CLOSE Get_Party_Csr;

/*** For the rules use the RULE API coded above for Price List ***/
 OPEN Get_Rule_Csr('BTO');
 FETCH Get_Rule_Csr INTO l_rule_rec;
 Close Get_Rule_Csr;

      x_contract_line_rec.bill_to_id := l_rule_rec.object1_id1;

 Open Get_Rule_Csr('SBG');
 Fetch Get_rule_Csr INTO  l_rule_rec;
 Close Get_Rule_Csr;

      x_contract_line_rec.bill_interval := l_rule_rec.rule_information1;


 For l_chr_rec in Get_hdr_det_csr(x_Contract_line_rec.hdr_id)
 Loop
       x_Contract_line_rec.currency_code:= l_chr_rec.currency_code;
       x_Contract_line_rec.customer_po_number:= l_chr_rec.cust_po_number;
  x_Contract_line_rec.class := 'SERVICE';
  x_Contract_line_rec.sub_class := l_chr_rec.scs_code;
 End Loop;

 x_Contract_line_rec.Accounting_rule_id := get_hdr_rule(X_Contract_line_rec.hdr_id,'ARL',G_JTF_Acctrule);
 x_Contract_line_rec.Invoice_rule_id    := get_hdr_rule(X_Contract_line_rec.hdr_id,'IRE',G_JTF_Invrule);
 x_Contract_line_rec.Payment_terms_id   := get_hdr_rule(X_Contract_line_rec.hdr_id,'PTR',G_JTF_Payterm);
 -- Beware!! Price_List_id is declared Number, function returns Varchar2
 x_Contract_line_rec.Price_list_id      := get_hdr_rule(X_Contract_line_rec.hdr_id,'PRE',G_JTF_Price);
 x_Contract_line_rec.Bill_to_id         := get_line_rule(p_contract_line_id,'BTO',G_JTF_Billto);
 x_Contract_line_rec.Ship_to_id         := get_line_rule(p_contract_line_id,'STO',G_JTF_Shipto);

/*** Do we need this ?? Probably not ***/
 OKC_TIME_UTIL_PUB.GET_DURATION (
                                 p_start_date    => x_Contract_line_rec.start_date ,
                                 p_end_date      => x_Contract_line_rec.end_date ,
                                 x_duration      => x_contract_line_rec.item_qty,
                                 x_timeunit      => x_contract_line_rec.item_uom_code,
                                 x_return_status => l_return_status
                               );

 OPEN Get_Cust_Csr(X_Contract_line_rec.Bill_to_id, x_contract_line_rec.party_id);
 FETCH Get_Cust_Csr INTO x_contract_line_rec.customer_acct_id;
 CLOSE Get_Cust_Csr;


EXCEPTION
     WHEN  G_EXCEPTION_HALT_VALIDATION Then
           x_return_status   :=   OKC_API.G_RET_STS_UNEXP_ERROR;
           OKC_API.set_message(G_APP_NAME,G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN,SQLERRM);
     WHEN  OTHERS Then
  ----Dbms_Output.Put_Line('OTHERS IN BUILD ' || sqlerrm);
           x_return_status   :=   OKC_API.G_RET_STS_UNEXP_ERROR;
           OKC_API.set_message(G_APP_NAME,G_UNEXPECTED_ERROR, G_SQLCODE_TOKEN, SQLCODE,G_SQLERRM_TOKEN, SQLERRM);
END;


--- This Procedure loads the pricing attribute table and is called to load
--- the sourced as well as user defined pricing attributes

Procedure Load_Pattr_Tbl(p_line_index  IN NUMBER,
                         p_pricing_context IN VARCHAR2,
                         p_pricing_attribute IN VARCHAR2,
                         p_pricing_attr_value IN VARCHAR2,
                         x_pattr_tbl  IN OUT NOCOPY QP_PREQ_GRP.LINE_ATTR_TBL_TYPE) IS
  i NUMBER;
BEGIN
  i := nvl(x_pattr_tbl.last,0) +1;
  x_pattr_tbl(i).Line_Index := p_Line_Index;
  x_pattr_tbl(i).Validated_Flag := 'Y';
  x_pattr_tbl(i).pricing_context := p_pricing_context;
  x_pattr_tbl(i).Pricing_Attribute := p_pricing_attribute;
  x_pattr_tbl(i).Pricing_Attr_Value_From :=p_pricing_attr_value;
END Load_Pattr_Tbl;

Procedure Load_Qual_Tbl(p_line_index  IN NUMBER,
                        p_qualifier_context IN VARCHAR2,
                        p_qualifier_attribute IN VARCHAR2,
                        p_qualifier_attr_value IN VARCHAR2,
                        x_qual_tbl  IN OUT NOCOPY QP_PREQ_GRP.QUAL_TBL_TYPE) IS
  i NUMBER;
BEGIN
  i := nvl(x_qual_tbl.last,0) +1;
  x_qual_tbl(i).Line_Index := p_Line_Index;
  x_qual_tbl(i).Validated_Flag := 'Y';
  x_qual_tbl(i).qualifier_context := p_qualifier_context;
  x_qual_tbl(i).qualifier_Attribute := p_qualifier_attribute;
  x_qual_tbl(i).qualifier_Attr_Value_From :=p_qualifier_attr_value;
  x_qual_tbl(i).qualifier_Attr_Value_To :=p_qualifier_attr_value;
  x_qual_tbl(i).comparison_operator_code := '=';
END Load_Qual_Tbl;

--  This Procedure will return the attributes sourced using QP dimension mapping

Procedure Load_Sourced_Pattrs(p_service_line_index   IN NUMBER,
                              p_pricing_contexts_tbl IN QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type,
                              px_Req_line_attr_tbl   IN OUT nocopy QP_PREQ_GRP.LINE_ATTR_TBL_TYPE) IS

BEGIN
  --- Load the pricing attributes of service item
  If p_pricing_contexts_tbl.exists(1)Then
    For i in p_pricing_contexts_Tbl.first .. p_pricing_contexts_Tbl.last
    Loop
      Load_Pattr_Tbl(p_line_index  => p_service_line_index,
                     p_pricing_context => p_pricing_contexts_tbl(i).context_name,
                     p_pricing_attribute => p_pricing_contexts_tbl(i).attribute_name,
                     p_pricing_attr_value => p_pricing_contexts_tbl(i).attribute_value,
                     x_pattr_tbl  => px_Req_line_attr_tbl);
    End Loop;
  End If;
END Load_Sourced_Pattrs;

--  This Procedure will return the user enterable pricing attributes in contracts

Procedure Load_User_Defined_Pattrs(p_contract_line_id   NUMBER,
                                   p_service_line_index NUMBER,
                                   px_Req_line_attr_tbl IN OUT NOCOPY QP_PREQ_GRP.LINE_ATTR_TBL_TYPE) IS
  cursor okc_pattr_cur is
  select pricing_context,
	    pricing_attribute1,  pricing_attribute2,  pricing_attribute3,  pricing_attribute4,
	    pricing_attribute5,  pricing_attribute6,  pricing_attribute7,  pricing_attribute8,
	    pricing_attribute9,  pricing_attribute10, pricing_attribute11, pricing_attribute12,
	    pricing_attribute13, pricing_attribute14, pricing_attribute15, pricing_attribute16,
	    pricing_attribute17, pricing_attribute18, pricing_attribute19, pricing_attribute20,
	    pricing_attribute21, pricing_attribute22, pricing_attribute23, pricing_attribute24,
	    pricing_attribute25, pricing_attribute26, pricing_attribute27, pricing_attribute28,
	    pricing_attribute29, pricing_attribute30, pricing_attribute31, pricing_attribute32,
	    pricing_attribute33, pricing_attribute34, pricing_attribute35, pricing_attribute36,
	    pricing_attribute37, pricing_attribute38, pricing_attribute39, pricing_attribute40,
	    pricing_attribute41, pricing_attribute42, pricing_attribute43, pricing_attribute44,
	    pricing_attribute45, pricing_attribute46, pricing_attribute47, pricing_attribute48,
	    pricing_attribute49, pricing_attribute50, pricing_attribute51, pricing_attribute52,
	    pricing_attribute53, pricing_attribute54, pricing_attribute55, pricing_attribute56,
	    pricing_attribute57, pricing_attribute58, pricing_attribute59, pricing_attribute60,
	    pricing_attribute61, pricing_attribute62, pricing_attribute63, pricing_attribute64,
	    pricing_attribute65, pricing_attribute66, pricing_attribute67, pricing_attribute68,
	    pricing_attribute69, pricing_attribute70, pricing_attribute71, pricing_attribute72,
	    pricing_attribute73, pricing_attribute74, pricing_attribute75, pricing_attribute76,
	    pricing_attribute77, pricing_attribute78, pricing_attribute79, pricing_attribute80,
	    pricing_attribute81, pricing_attribute82, pricing_attribute83, pricing_attribute84,
	    pricing_attribute85, pricing_attribute86, pricing_attribute87, pricing_attribute88,
	    pricing_attribute89, pricing_attribute90, pricing_attribute91, pricing_attribute92,
	    pricing_attribute93, pricing_attribute94, pricing_attribute95, pricing_attribute96,
	    pricing_attribute97, pricing_attribute98, pricing_attribute99, pricing_attribute100
    from okc_price_att_values_v
   where cle_id = p_contract_line_id;
  Procedure Load_Tbl(p_prc_context Varchar2,
                     p_prc_attr Varchar2,
                     p_prc_attr_value Varchar2) Is
  Begin
    If p_prc_attr_value Is Not Null Then
      LOAD_PATTR_TBL(p_line_index  => p_service_line_index,
                     p_pricing_context => p_prc_context,
                     p_pricing_attribute => p_prc_attr,
                     p_pricing_attr_value => p_prc_attr_value,
                     x_pattr_tbl  => px_req_line_attr_tbl);
    End If;
  End;
BEGIN
 For OKC_pattr_rec in OKC_pattr_cur Loop
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE1', OKC_pattr_rec.PRICING_ATTRIBUTE1);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE2', OKC_pattr_rec.PRICING_ATTRIBUTE2);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE3', OKC_pattr_rec.PRICING_ATTRIBUTE3);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE4', OKC_pattr_rec.PRICING_ATTRIBUTE4);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE5', OKC_pattr_rec.PRICING_ATTRIBUTE5);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE6', OKC_pattr_rec.PRICING_ATTRIBUTE6);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE7', OKC_pattr_rec.PRICING_ATTRIBUTE7);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE8', OKC_pattr_rec.PRICING_ATTRIBUTE8);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE9', OKC_pattr_rec.PRICING_ATTRIBUTE9);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE10', OKC_pattr_rec.PRICING_ATTRIBUTE10);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE11', OKC_pattr_rec.PRICING_ATTRIBUTE11);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE12', OKC_pattr_rec.PRICING_ATTRIBUTE12);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE13', OKC_pattr_rec.PRICING_ATTRIBUTE13);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE14', OKC_pattr_rec.PRICING_ATTRIBUTE14);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE15', OKC_pattr_rec.PRICING_ATTRIBUTE15);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE16', OKC_pattr_rec.PRICING_ATTRIBUTE16);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE17', OKC_pattr_rec.PRICING_ATTRIBUTE17);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE18', OKC_pattr_rec.PRICING_ATTRIBUTE18);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE19', OKC_pattr_rec.PRICING_ATTRIBUTE19);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE20', OKC_pattr_rec.PRICING_ATTRIBUTE20);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE21', OKC_pattr_rec.PRICING_ATTRIBUTE21);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE22', OKC_pattr_rec.PRICING_ATTRIBUTE22);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE23', OKC_pattr_rec.PRICING_ATTRIBUTE23);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE24', OKC_pattr_rec.PRICING_ATTRIBUTE24);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE25', OKC_pattr_rec.PRICING_ATTRIBUTE25);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE26', OKC_pattr_rec.PRICING_ATTRIBUTE26);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE27', OKC_pattr_rec.PRICING_ATTRIBUTE27);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE28', OKC_pattr_rec.PRICING_ATTRIBUTE28);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE29', OKC_pattr_rec.PRICING_ATTRIBUTE29);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE30', OKC_pattr_rec.PRICING_ATTRIBUTE30);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE31', OKC_pattr_rec.PRICING_ATTRIBUTE31);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE32', OKC_pattr_rec.PRICING_ATTRIBUTE32);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE33', OKC_pattr_rec.PRICING_ATTRIBUTE33);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE34', OKC_pattr_rec.PRICING_ATTRIBUTE34);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE35', OKC_pattr_rec.PRICING_ATTRIBUTE35);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE36', OKC_pattr_rec.PRICING_ATTRIBUTE36);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE37', OKC_pattr_rec.PRICING_ATTRIBUTE37);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE38', OKC_pattr_rec.PRICING_ATTRIBUTE38);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE39', OKC_pattr_rec.PRICING_ATTRIBUTE39);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE40', OKC_pattr_rec.PRICING_ATTRIBUTE40);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE41', OKC_pattr_rec.PRICING_ATTRIBUTE41);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE42', OKC_pattr_rec.PRICING_ATTRIBUTE42);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE43', OKC_pattr_rec.PRICING_ATTRIBUTE43);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE44', OKC_pattr_rec.PRICING_ATTRIBUTE44);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE45', OKC_pattr_rec.PRICING_ATTRIBUTE45);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE46', OKC_pattr_rec.PRICING_ATTRIBUTE46);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE47', OKC_pattr_rec.PRICING_ATTRIBUTE47);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE48', OKC_pattr_rec.PRICING_ATTRIBUTE48);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE49', OKC_pattr_rec.PRICING_ATTRIBUTE49);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE50', OKC_pattr_rec.PRICING_ATTRIBUTE50);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE51', OKC_pattr_rec.PRICING_ATTRIBUTE51);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE52', OKC_pattr_rec.PRICING_ATTRIBUTE52);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE53', OKC_pattr_rec.PRICING_ATTRIBUTE53);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE54', OKC_pattr_rec.PRICING_ATTRIBUTE54);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE55', OKC_pattr_rec.PRICING_ATTRIBUTE55);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE56', OKC_pattr_rec.PRICING_ATTRIBUTE56);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE57', OKC_pattr_rec.PRICING_ATTRIBUTE57);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE58', OKC_pattr_rec.PRICING_ATTRIBUTE58);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE59', OKC_pattr_rec.PRICING_ATTRIBUTE59);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE60', OKC_pattr_rec.PRICING_ATTRIBUTE60);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE61', OKC_pattr_rec.PRICING_ATTRIBUTE61);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE62', OKC_pattr_rec.PRICING_ATTRIBUTE62);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE63', OKC_pattr_rec.PRICING_ATTRIBUTE63);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE64', OKC_pattr_rec.PRICING_ATTRIBUTE64);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE65', OKC_pattr_rec.PRICING_ATTRIBUTE65);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE66', OKC_pattr_rec.PRICING_ATTRIBUTE66);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE67', OKC_pattr_rec.PRICING_ATTRIBUTE67);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE68', OKC_pattr_rec.PRICING_ATTRIBUTE68);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE69', OKC_pattr_rec.PRICING_ATTRIBUTE69);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE70', OKC_pattr_rec.PRICING_ATTRIBUTE70);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE71', OKC_pattr_rec.PRICING_ATTRIBUTE71);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE72', OKC_pattr_rec.PRICING_ATTRIBUTE72);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE73', OKC_pattr_rec.PRICING_ATTRIBUTE73);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE74', OKC_pattr_rec.PRICING_ATTRIBUTE74);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE75', OKC_pattr_rec.PRICING_ATTRIBUTE75);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE76', OKC_pattr_rec.PRICING_ATTRIBUTE76);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE77', OKC_pattr_rec.PRICING_ATTRIBUTE77);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE78', OKC_pattr_rec.PRICING_ATTRIBUTE78);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE79', OKC_pattr_rec.PRICING_ATTRIBUTE79);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE80', OKC_pattr_rec.PRICING_ATTRIBUTE80);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE81', OKC_pattr_rec.PRICING_ATTRIBUTE81);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE82', OKC_pattr_rec.PRICING_ATTRIBUTE82);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE83', OKC_pattr_rec.PRICING_ATTRIBUTE83);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE84', OKC_pattr_rec.PRICING_ATTRIBUTE84);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE85', OKC_pattr_rec.PRICING_ATTRIBUTE85);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE86', OKC_pattr_rec.PRICING_ATTRIBUTE86);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE87', OKC_pattr_rec.PRICING_ATTRIBUTE87);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE88', OKC_pattr_rec.PRICING_ATTRIBUTE88);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE89', OKC_pattr_rec.PRICING_ATTRIBUTE89);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE90', OKC_pattr_rec.PRICING_ATTRIBUTE90);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE91', OKC_pattr_rec.PRICING_ATTRIBUTE91);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE92', OKC_pattr_rec.PRICING_ATTRIBUTE92);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE93', OKC_pattr_rec.PRICING_ATTRIBUTE93);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE94', OKC_pattr_rec.PRICING_ATTRIBUTE94);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE95', OKC_pattr_rec.PRICING_ATTRIBUTE95);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE96', OKC_pattr_rec.PRICING_ATTRIBUTE96);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE97', OKC_pattr_rec.PRICING_ATTRIBUTE97);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE98', OKC_pattr_rec.PRICING_ATTRIBUTE98);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE99', OKC_pattr_rec.PRICING_ATTRIBUTE99);
   LOAD_TBL(OKC_pattr_rec.pricing_context, 'PRICING_ATTRIBUTE100', OKC_pattr_rec.PRICING_ATTRIBUTE100);

   /* If OKC_pattr_rec.PRICING_ATTRIBUTE100 is not null Then
     LOAD_PATTR_TBL(p_line_index  => p_service_line_index,
                    p_pricing_context => OKC_pattr_rec.pricing_context,
                    p_pricing_attribute => 'PRICING_ATTRIBUTE100',
                    p_pricing_attr_value => OKC_pattr_rec.PRICING_ATTRIBUTE100,
                    x_pattr_tbl  => px_req_line_attr_tbl);
   End If; */
 End Loop;
END Load_User_Defined_Pattrs;

/**** Load Lines is used for PB_Tbl_flag = N and usage item = N
For this condition the Req_Line-TBL gets two records - one from Kline and from CP_Tbl
Also Req_Line_Attr_Tbl gets two similar records
Req_Qual_Tbl gets two price list record and one modifier record
Might want to check this out nocopy  ***/

Procedure Load_Lines(p_line_rec               IN OKC_PRICE_PUB.G_LINE_REC_TYPE,
                     p_cp_Line_tbl            IN OKC_PRICE_PUB.G_SLINE_TBL_TYPE,
                     p_get_pb_tbl_flag        IN Varchar2,
                     p_price_list_id          IN Number,
                     p_modifier_list_id       IN Number,
                     p_pricing_contexts_tbl   IN QP_ATTR_MAPPING_PUB.CONTEXTS_RESULT_TBL_TYPE,
                     px_req_line_tbl          IN OUT NOCOPY QP_PREQ_GRP.LINE_TBL_TYPE,
                     px_Req_line_attr_tbl     IN OUT NOCOPY QP_PREQ_GRP.LINE_ATTR_TBL_TYPE,
                     px_req_related_lines_tbl IN OUT NOCOPY QP_PREQ_GRP.RELATED_LINES_TBL_TYPE,
                     px_req_qual_tbl          IN OUT NOCOPY QP_PREQ_GRP.QUAL_TBL_TYPE) IS
  l_line_index  NUMBER := 0;
  l_related_lines_Index NUMBER := 0;
  l_attr_index  NUMBER := 0;
  l_qual_attr_index NUMBER := 0;
BEGIN
  If p_get_pb_tbl_flag = 'Y' AND p_line_rec.usage_item_flag = 'Y' Then
  --- Get only price break information. Used only for Service Contracts
    l_line_index := l_line_index+1;
    px_req_line_tbl(l_line_index).LINE_INDEX := l_line_index;
    px_req_line_tbl(l_line_index).LINE_TYPE_CODE := 'LINE';
    px_req_line_tbl(l_line_index).REQUEST_TYPE_CODE := OKC_PRICE_PUB.G_REQUEST_TYPE_CODE;
    px_req_line_tbl(l_line_index).CURRENCY_CODE := p_Line_rec.currency_code;
    px_req_line_tbl(l_line_index).PRICING_EFFECTIVE_DATE := sysdate;
    px_req_line_tbl(l_line_index).ACTIVE_DATE_FIRST :=
				 px_req_line_tbl(l_line_index).PRICING_EFFECTIVE_DATE;
    px_req_line_tbl(l_line_index).ACTIVE_DATE_FIRST_TYPE := 'NO TYPE';
    px_req_line_tbl(l_line_index).LINE_QUANTITY := p_line_rec.item_qty;
    px_req_line_tbl(l_line_index).LINE_UOM_CODE := p_line_rec.item_uom_code;
    px_req_line_tbl(l_line_index).PRICE_FLAG := 'Y';

    --- Load the pricing attribute For this item
    Load_Pattr_Tbl(p_line_index  => l_line_index,
                   p_pricing_context => OKC_PRICE_PUB.G_ITEM_CONTEXT,
                   p_pricing_attribute => OKC_PRICE_PUB.G_ITEM_ATTR,
                   p_pricing_attr_value => p_line_rec.inventory_item_id,
                   x_pattr_tbl  => px_Req_line_attr_tbl);

    Load_Pattr_Tbl(p_line_index  => l_line_index,
                   p_pricing_context => OKC_PRICE_PUB.G_VOLUME_CONTEXT,
                   p_pricing_attribute => OKC_PRICE_PUB.G_VOLUME_ATTR,
                   p_pricing_attr_value => p_line_rec.item_qty,
                   x_pattr_tbl  => px_Req_line_attr_tbl);

    --- Load the Price list as qualifier For serviceable item since we know which price list to use
    --- We do not use modifier list For serviceable items
    Load_Qual_Tbl(p_line_index  => l_line_index,
                  p_qualifier_context => OKC_PRICE_PUB.G_LIST_CONTEXT,
                  p_qualifier_attribute => OKC_PRICE_PUB.G_LIST_PRICE_ATTR,
                  p_qualifier_attr_value => p_price_list_id,
                  x_qual_tbl  => px_Req_qual_tbl);
  Else
    --- Calculate price
    --- Load Serviceable Item records into request. This must be done prior to service item according to QP
    For i in p_cp_line_tbl.first .. p_cp_line_tbl.last
    Loop
      --- Load the serviceable item first
      l_line_index := l_line_index+1;
      px_req_line_tbl(l_line_index).LINE_INDEX := l_line_index;
      px_req_line_tbl(l_line_index).LINE_TYPE_CODE := 'LINE';
      px_req_line_tbl(l_line_index).REQUEST_TYPE_CODE := OKC_PRICE_PUB.G_REQUEST_TYPE_CODE;
      px_req_line_tbl(l_line_index).CURRENCY_CODE := p_line_rec.currency_code;
      px_req_line_tbl(l_line_index).PRICING_EFFECTIVE_DATE := sysdate;
      px_req_line_tbl(l_line_index).ACTIVE_DATE_FIRST :=
				 px_req_line_tbl(l_line_index).PRICING_EFFECTIVE_DATE;
      px_req_line_tbl(l_line_index).ACTIVE_DATE_FIRST_TYPE := 'NO TYPE';
      px_req_line_tbl(l_line_index).LINE_QUANTITY := p_cp_line_tbl(i).item_qty;
      px_req_line_tbl(l_line_index).LINE_UOM_CODE := p_cp_line_tbl(i).item_uom_code;
      px_req_line_tbl(l_line_index).PRICE_FLAG := 'Y';

      --- Load the pricing attribute For this item

      If nvl(p_line_rec.usage_item_flag, 'N') = 'N' Then
        Load_Pattr_Tbl(p_line_index  => l_line_index,
                       p_pricing_context => OKC_PRICE_PUB.G_ITEM_CONTEXT,
                       p_pricing_attribute => OKC_PRICE_PUB.G_ITEM_ATTR,
                       p_pricing_attr_value => p_cp_line_tbl(i).inventory_item_id,
                       x_pattr_tbl  => px_Req_line_attr_tbl);
      Else
        Load_Pattr_Tbl(p_line_index  => l_line_index,
                       p_pricing_context => OKC_PRICE_PUB.G_ITEM_CONTEXT,
                       p_pricing_attribute => OKC_PRICE_PUB.G_ITEM_ATTR,
                       p_pricing_attr_value => p_line_rec.inventory_item_id,
                       x_pattr_tbl  => px_Req_line_attr_tbl);

        --- For usage items, QP requires quantity as pricing attr rather than item qty
        Load_Pattr_Tbl(p_line_index  => l_line_index,
                       p_pricing_context => OKC_PRICE_PUB.G_VOLUME_CONTEXT,
                       p_pricing_attribute => OKC_PRICE_PUB.G_VOLUME_ATTR,
                       p_pricing_attr_value => p_cp_line_tbl(i).item_qty,
                       x_pattr_tbl  => px_Req_line_attr_tbl);
      End If;

      --- Load the Price list as qualifier For serviceable item since we know which price list to use
      --- We do not use modifier list For serviceable items

      Load_Qual_Tbl(p_line_index  => l_line_index,
                    p_qualifier_context => OKC_PRICE_PUB.G_LIST_CONTEXT,
                    p_qualifier_attribute => OKC_PRICE_PUB.G_LIST_PRICE_ATTR,
                    p_qualifier_attr_value => p_price_list_id,
                    x_qual_tbl  => px_Req_qual_tbl);
      -- Commented out the following since core contracts will be passing exactly one
      -- item and not multiple like the service contracts
      /* If nvl(p_line_rec.usage_item_flag, 'N') = 'N' Then
        --- Load the service item
        l_line_index := l_line_index+1;
        px_req_line_tbl(l_line_index).LINE_INDEX := l_line_index;
        px_req_line_tbl(l_line_index).LINE_TYPE_CODE := 'LINE';
        px_req_line_tbl(l_line_index).REQUEST_TYPE_CODE := OKC_PRICE_PUB.G_REQUEST_TYPE_CODE;
        px_req_line_tbl(l_line_index).CURRENCY_CODE := p_Line_rec.currency_code;
        px_req_line_tbl(l_line_index).PRICING_EFFECTIVE_DATE := sysdate;
        px_req_line_tbl(l_line_index).ACTIVE_DATE_FIRST :=
			   px_req_line_tbl(l_line_index).PRICING_EFFECTIVE_DATE;
        px_req_line_tbl(l_line_index).ACTIVE_DATE_FIRST_TYPE := 'NO TYPE';
        px_req_line_tbl(l_line_index).LINE_QUANTITY := p_Line_rec.item_qty;
        px_req_line_tbl(l_line_index).LINE_UOM_CODE := p_Line_rec.item_uom_code;
        px_req_line_tbl(l_line_index).PRICE_FLAG := 'Y';

        --- Load the pricing attribute For service/usage item
        LOAD_PATTR_TBL(p_line_index  => l_line_index,
                       p_pricing_context => OKC_PRICE_PUB.G_ITEM_CONTEXT,
                       p_pricing_attribute => OKC_PRICE_PUB.G_ITEM_ATTR,
                       p_pricing_attr_value => p_line_rec.inventory_item_id,
                       x_pattr_tbl  => px_Req_line_attr_tbl);

        --- Load the Price list list as qualifier For service/usage item
        Load_Qual_Tbl(p_line_index  => l_line_index,
                      p_qualifier_context => OKC_PRICE_PUB.G_LIST_CONTEXT,
                      p_qualifier_attribute => OKC_PRICE_PUB.G_LIST_PRICE_ATTR,
                      p_qualifier_attr_value => p_price_list_id,
                      x_qual_tbl  => px_Req_qual_tbl);

        --- Load the Modifier list list as qualifier For service item
        If p_modifier_list_id IS NOT NULL Then
          Load_Qual_Tbl(p_line_index  => l_line_index,
                        p_qualifier_context => OKC_PRICE_PUB.G_LIST_CONTEXT,
                        p_qualifier_attribute => OKC_PRICE_PUB.G_LIST_MODIFIER_ATTR,
                        p_qualifier_attr_value => p_modifier_list_id,
                        x_qual_tbl  => px_Req_qual_tbl);
        End If;

        --- Set the relationship between service/serviceable items
        --- Last line in the request line table is the service item other lines are serviceable items

        l_related_lines_Index := nvl(px_Req_related_lines_tbl.last,0) + 1;
        px_Req_related_lines_tbl(l_related_lines_Index).Line_Index := l_line_index;
        px_Req_related_lines_tbl(l_related_lines_Index).Line_Detail_Index := 0;
        px_Req_related_lines_tbl(l_related_lines_Index).Related_Line_Index := l_line_index - 1;
        px_Req_related_lines_tbl(l_related_lines_Index).Related_Line_Detail_Index := 0;
        px_Req_related_lines_tbl(l_related_lines_Index).Relationship_Type_Code :=  QP_PREQ_GRP.G_SERVICE_LINE;
        --Dbms_Output.Put_Line('RELATED LINE INDEX ' || l_line_index);
        --Dbms_Output.Put_Line('RELATED DETAIL LINE INDEX ' || i);
        --Dbms_Output.Put_Line('G_SERVICE LINE ' || QP_PREQ_GRP.G_SERVICE_LINE);

      End If; */
    End Loop;
  End If;
END Load_LineS;

Procedure Call_QP(p_contract_line_rec        IN OKC_PRICE_PUB.G_LINE_REC_TYPE,
                  p_contract_cp_tbl          IN OUT NOCOPY OKC_PRICE_PUB.G_SLINE_TBL_TYPE,
                  p_get_pb_tbl_flag          IN VARCHAR2,
                  x_req_line_tbl             OUT  NOCOPY QP_PREQ_GRP.LINE_TBL_TYPE,
                  x_Req_qual_tbl             OUT  NOCOPY QP_PREQ_GRP.QUAL_TBL_TYPE,
                  x_Req_line_attr_tbl        OUT  NOCOPY QP_PREQ_GRP.LINE_ATTR_TBL_TYPE,
                  x_Req_LINE_DETAIL_tbl      OUT  NOCOPY QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE,
                  x_Req_LINE_DETAIL_qual_tbl OUT  NOCOPY QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE,
                  x_Req_LINE_DETAIL_attr_tbl OUT  NOCOPY QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE,
                  x_Req_related_lines_tbl    OUT  NOCOPY QP_PREQ_GRP.RELATED_LINES_TBL_TYPE,
                  x_return_status            OUT  NOCOPY Varchar2,
                  x_return_status_text       OUT  NOCOPY Varchar2) IS
  l_return_status            Varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
  l_return_status_text       Varchar2(240);
  l_Req_line_tbl             QP_PREQ_GRP.LINE_TBL_TYPE;
  l_Req_qual_tbl             QP_PREQ_GRP.QUAL_TBL_TYPE;
  l_Req_line_attr_tbl        QP_PREQ_GRP.LINE_ATTR_TBL_TYPE;
  l_Req_LINE_DETAIL_tbl      QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE;
  l_Req_LINE_DETAIL_qual_tbl QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE;
  l_Req_LINE_DETAIL_attr_tbl QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE;
  l_Req_related_lines_tbl    QP_PREQ_GRP.RELATED_LINES_TBL_TYPE;
  l_pricing_contexts_Tbl     QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type;
  l_qualifier_contexts_Tbl   QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type;
  i                          Number;

Begin
  x_return_status  := OKC_API.G_RET_STS_SUCCESS;
  G_CONTROL_REC.pricing_event := OKC_PRICE_PUB.G_PRICING_EVENT;
  G_CONTROL_REC.calculate_flag := 'Y';
  G_CONTROL_REC.simulation_flag  := 'N';

  QP_Attr_Mapping_PUB.Build_Contexts(p_request_type_code   => OKC_PRICE_PUB.G_REQUEST_TYPE_CODE,
                                     p_pricing_type   => 'L',
                                     x_price_contexts_result_tbl  => l_pricing_contexts_Tbl,
                                     x_qual_contexts_result_tbl   => l_qualifier_Contexts_Tbl);

  -- Build line Request including price/modifier list as qualifiers and related lines
  Load_Lines(p_line_rec               => p_contract_line_rec,
             p_cp_Line_tbl            => p_contract_cp_tbl,
             p_get_pb_tbl_flag        => p_get_pb_tbl_flag,
             p_price_list_id          => p_contract_line_rec.price_list_id,
             p_modifier_list_id       => p_contract_line_rec.modifier_list_id,
             p_pricing_contexts_tbl   => l_pricing_contexts_Tbl,
             px_req_line_tbl          => l_req_line_tbl,
             px_req_line_attr_tbl     => l_req_line_attr_tbl,
             px_req_related_lines_tbl => l_req_related_lines_tbl,
             px_req_qual_tbl          => l_req_qual_tbl);

  Load_Sourced_Pattrs(p_service_line_index    => l_req_line_tbl.last,
                      p_pricing_contexts_tbl  => l_pricing_contexts_tbl,
                      px_req_line_attr_tbl    => l_req_line_attr_tbl);

  Load_User_Defined_Pattrs(p_contract_line_id  => p_contract_line_rec.line_id,
                           p_service_line_index  => l_req_line_tbl.last,
                           px_req_line_attr_tbl  => l_req_line_attr_tbl);

/*  If Nvl(l_req_line_tbl.count,0 ) > 0 Then
    Dbms_Output.Put_Line('-------------Line Information-------------------');
    For i in l_req_line_tbl.first .. l_req_line_tbl.last
    Loop
      Dbms_Output.Put_Line('line_index: '||l_req_line_tbl(I).line_index);
      Dbms_Output.Put_Line(' line id: '||l_req_line_tbl(I).line_id);
      Dbms_Output.Put_Line(' Unit_price: '||l_req_line_tbl(I).unit_price);
      Dbms_Output.Put_Line(' Percent price: '||l_req_line_tbl(I).percent_price);
      Dbms_Output.Put_Line(' Line quantity: '||l_req_line_tbl(I).line_quantity);
      Dbms_Output.Put_Line(' Parent  price: '||l_req_line_tbl(I).parent_price);
      Dbms_Output.Put_Line(' Parent  quant: '||l_req_line_tbl(I).parent_quantity);
      Dbms_Output.Put_Line(' Adjusted unit price: '||l_req_line_tbl(I).adjusted_unit_price);
      Dbms_Output.Put_Line(' Line UOM Code : '||l_req_line_tbl(I).line_uom_code);
      Dbms_Output.Put_Line(' UOM Quantity  : '||l_req_line_tbl(I).uom_quantity);
      Dbms_Output.Put_Line(' Currency Code : '||l_req_line_tbl(I).currency_code);
      Dbms_Output.Put_Line(' Pricing status code: '||l_req_line_tbl(I).status_code);
      Dbms_Output.Put_Line(' Pricing quantity: '||l_req_line_tbl(I).priced_quantity);
      Dbms_Output.Put_Line(' Pricing uom code code: '||l_req_line_tbl(I).priced_uom_code);
      Dbms_Output.Put_Line(' Pricing status text: '||l_req_line_tbl(I).status_text);
    End Loop;
  End If;

  If nvl(l_req_qual_tbl.count,0 ) > 0 Then
    Dbms_Output.Put_Line('-------------Qualifier Information-------------------');
    For i in l_req_qual_tbl.first .. l_req_qual_tbl.last
    Loop
      Dbms_Output.Put_Line('line_index: '||l_req_qual_tbl(I).line_index);
      Dbms_Output.Put_Line(' qual context: '||l_req_qual_tbl(I).qualifier_context);
      Dbms_Output.Put_Line(' qual attr: '||l_req_qual_tbl(I).qualifier_attribute);
      Dbms_Output.Put_Line(' qual attr value from: '||l_req_qual_tbl(I).qualifier_attr_value_from);
      Dbms_Output.Put_Line(' qual attr value to: '||l_req_qual_tbl(I).qualifier_attr_value_to);
      Dbms_Output.Put_Line(' comp opn code: '||l_req_qual_tbl(I).comparison_operator_code);
      Dbms_Output.Put_Line(' validated flag: '||l_req_qual_tbl(I).validated_flag);
      Dbms_Output.Put_Line(' status code: '||l_req_qual_tbl(I).status_code);
      Dbms_Output.Put_Line(' status text: '||l_req_qual_tbl(I).status_text);
    End Loop;
  End If;

  If nvl(l_Req_line_attr_tbl.count,0 ) > 0 Then
    Dbms_Output.Put_Line('-------------Line Attr Information-------------------');
    For i in l_Req_line_attr_tbl.first .. l_Req_line_attr_tbl.last
    Loop
      Dbms_Output.Put_Line('line_index: '||l_Req_line_attr_tbl(I).line_index);
      Dbms_Output.Put_Line(' Prc context: '||l_Req_line_attr_tbl(I).pricing_context);
      Dbms_Output.Put_Line(' Prc attr: '||l_Req_line_attr_tbl(I).pricing_attribute);
      Dbms_Output.Put_Line(' Prc attr value from: '||l_Req_line_attr_tbl(I).pricing_attr_value_from);
      Dbms_Output.Put_Line(' Prc attr value to: '||l_Req_line_attr_tbl(I).pricing_attr_value_to);
      Dbms_Output.Put_Line(' validated flag: '||l_Req_line_attr_tbl(I).validated_flag);
      Dbms_Output.Put_Line(' status code: '||l_Req_line_attr_tbl(I).status_code);
      Dbms_Output.Put_Line(' status text: '||l_Req_line_attr_tbl(I).status_text);
    End Loop;
  End If;

  If nvl(l_req_line_detail_tbl.count,0)  > 0 Then
    Dbms_Output.Put_Line('------------Line Detail Information------------ ');
    For I in l_req_line_detail_tbl.first .. l_req_line_detail_tbl.last
    Loop
      Dbms_Output.Put_Line(' I ' || I || 'Count ' ||  l_req_line_detail_tbl.count);
      Dbms_Output.Put_Line('line_detail_index: '||l_req_line_detail_tbl(I).line_detail_index);
      Dbms_Output.Put_Line(' line detail type:'||l_req_line_detail_tbl(I).line_detail_type_code);
      Dbms_Output.Put_Line(' line_index: '||l_req_line_detail_tbl(I).line_index);
      Dbms_Output.Put_Line(' list_header_id: '||l_req_line_detail_tbl(I).list_header_id);
      Dbms_Output.Put_Line(' list_line_id: '||l_req_line_detail_tbl(I).list_line_id);
      Dbms_Output.Put_Line(' list_line_type_code: '||l_req_line_detail_tbl(I).list_line_type_code);
      Dbms_Output.Put_Line(' Adjustment Amount : '||l_req_line_detail_tbl(I).adjustment_amount);
      Dbms_Output.Put_Line(' Line Quantity : '||l_req_line_detail_tbl(I).line_quantity);
      Dbms_Output.Put_Line(' List Price : '||l_req_line_detail_tbl(I).list_price);
      Dbms_Output.Put_Line(' Operand_calculation_code: '||l_req_line_detail_tbl(I).Operand_calculation_code);
      Dbms_Output.Put_Line(' Operand value: '||l_req_line_detail_tbl(I).operand_value);
      Dbms_Output.Put_Line(' Automatic Flag: '||l_req_line_detail_tbl(I).automatic_flag);
      Dbms_Output.Put_Line(' Overide Flag: '||l_req_line_detail_tbl(I).override_flag);
      Dbms_Output.Put_Line(' status_code: '||l_req_line_detail_tbl(I).status_code);
      Dbms_Output.Put_Line(' status text: '||l_req_line_detail_tbl(I).status_text);
      Dbms_Output.Put_Line('-------------------------------------------');
    End Loop;
  End If;

  If nvl(l_req_related_lines_tbl.count,0) > 0 Then
    Dbms_Output.Put_Line('--------------Related Lines Information---------------');
    For i in l_req_related_lines_tbl.first .. l_req_related_lines_tbl.last
    Loop
      Dbms_Output.Put_Line('Line Index :'||l_req_related_lines_tbl(I).line_index);
      Dbms_Output.Put_Line('Line detail index: '||l_req_related_lines_tbl(I).LINE_DETAIL_INDEX);
      Dbms_Output.Put_Line(' Relationship type code: '||l_req_related_lines_tbl(I).relationship_type_code);
      Dbms_Output.Put_Line(' Related Line Index: '||l_req_related_lines_tbl(I).RELATED_LINE_INDEX);
      Dbms_Output.Put_Line(' Related line detail index: '||l_req_related_lines_tbl(I).related_line_detail_index);
      Dbms_Output.Put_Line(' Status Code: '|| l_req_related_lines_tbl(I).STATUS_CODE);
    End Loop;
  End If;

  If nvl(l_req_line_detail_attr_tbl.count,0) > 0 Then
    Dbms_Output.Put_Line('-----------Attributes Information-------------');
    For i in l_req_line_detail_attr_tbl.first .. l_req_line_detail_attr_tbl.last
    Loop
      Dbms_Output.Put_Line('Line detail INDEX '||l_req_line_detail_attr_tbl(I).line_detail_index);
      Dbms_Output.Put_Line(' Pricing Context '||l_req_line_detail_attr_tbl(I).pricing_context);
      Dbms_Output.Put_Line(' Pricing attribute '||l_req_line_detail_attr_tbl(I).pricing_attribute);
      Dbms_Output.Put_Line(' Pricing attr value from '||l_req_line_detail_attr_tbl(I).pricing_attr_value_from);
      Dbms_Output.Put_Line(' Pircing attr value to '||l_req_line_detail_attr_tbl(I).pricing_attr_value_to);
      Dbms_Output.Put_Line(' Status Code '||l_req_line_detail_attr_tbl(I).status_code);
    End Loop;
  End If;

  If nvl(l_req_line_detail_qual_tbl.count,0) > 0 Then
    Dbms_Output.Put_Line('-----------Qualifier Attributes Information-------------');
    For i in l_req_line_detail_qual_tbl.first .. l_req_line_detail_qual_tbl.last
    Loop
      Dbms_Output.Put_Line('Line detail INDEX '||l_req_line_detail_qual_tbl(I).line_detail_index);
      Dbms_Output.Put_Line(' Qualifier Context '||l_req_line_detail_qual_tbl(I).qualifier_context);
      Dbms_Output.Put_Line(' Qualifier attribute '||l_req_line_detail_qual_tbl(I).qualifier_attribute);
      Dbms_Output.Put_Line(' Qualifier attr value from '||l_req_line_detail_qual_tbl(I).qualifier_attr_value_from);
      Dbms_Output.Put_Line(' Qualifier attr value to '||l_req_line_detail_qual_tbl(I).qualifier_attr_value_to);
      Dbms_Output.Put_Line(' Status Code '||l_req_line_detail_qual_tbl(I).status_code);
      Dbms_Output.Put_Line('---------------------------------------------------');
    End Loop;
  End If; */
  QP_PREQ_GRP.PRICE_REQUEST(p_control_rec           => G_CONTROL_REC,
                            p_line_tbl              => l_Req_line_tbl,
                            p_qual_tbl              => l_Req_qual_tbl,
                            p_line_attr_tbl         => l_Req_line_attr_tbl,
                            p_line_detail_tbl       => l_req_line_detail_tbl,
                            p_line_detail_qual_tbl  => l_req_line_detail_qual_tbl,
                            p_line_detail_attr_tbl  => l_req_line_detail_attr_tbl,
                            p_related_lines_tbl     => l_req_related_lines_tbl,
                            x_line_tbl              => x_req_line_tbl,
                            x_line_qual             => x_Req_qual_tbl,
                            x_line_attr_tbl         => x_Req_line_attr_tbl,
                            x_line_detail_tbl       => x_req_line_detail_tbl,
                            x_line_detail_qual_tbl  => x_req_line_detail_qual_tbl,
                            x_line_detail_attr_tbl  => x_req_line_detail_attr_tbl,
                            x_related_lines_tbl     => x_req_related_lines_tbl,
                            x_return_status         => l_return_status,
                            x_return_status_text    => l_return_status_text);

  x_return_status := l_return_status;
  x_return_status_text := l_return_status_text;

  /* Dbms_Output.Put_Line('Error is '|| sqlerrm);
  Dbms_Output.Put_Line('After QP : Return Status text : '||  l_return_status || ' : ' || l_return_status_text);
  Dbms_Output.Put_Line('+---------Information returned to caller:---------------------+ ');

  If nvl(x_req_line_tbl.count,0 ) > 0 Then
    Dbms_Output.Put_Line('-------------Line Information-------------------');
    For i in x_req_line_tbl.first .. x_req_line_tbl.last
    Loop
      Dbms_Output.Put_Line('Row index: '||i);
      Dbms_Output.Put_Line('line_index: '||x_req_line_tbl(I).line_index);
      Dbms_Output.Put_Line(' line id: '||x_req_line_tbl(I).line_id);
      Dbms_Output.Put_Line(' Unit_price: '||x_req_line_tbl(I).unit_price);
      Dbms_Output.Put_Line(' Percent price: '||x_req_line_tbl(I).percent_price);
      Dbms_Output.Put_Line(' Line quantity: '||x_req_line_tbl(I).line_quantity);
      Dbms_Output.Put_Line(' Parent  price: '||x_req_line_tbl(I).parent_price);
      Dbms_Output.Put_Line(' Parent  quant: '||x_req_line_tbl(I).parent_quantity);
      Dbms_Output.Put_Line(' Adjusted unit price: '||x_req_line_tbl(I).adjusted_unit_price);
      Dbms_Output.Put_Line(' Line UOM Code : '||x_req_line_tbl(I).line_uom_code);
      Dbms_Output.Put_Line(' UOM Quantity  : '||x_req_line_tbl(I).uom_quantity);
      Dbms_Output.Put_Line(' Pricing status code: '||x_req_line_tbl(I).status_code);
      Dbms_Output.Put_Line(' Pricing quantity: '||x_req_line_tbl(I).priced_quantity);
      Dbms_Output.Put_Line(' Pricing uom code code: '||x_req_line_tbl(I).priced_uom_code);
      Dbms_Output.Put_Line(' Pricing status text: '||x_req_line_tbl(I).status_text);
    End Loop;
  End If;

  If nvl(x_req_qual_tbl.count,0 ) > 0 Then
    Dbms_Output.Put_Line('-------------Qualifier Information-------------------');
    For i in x_req_qual_tbl.first .. x_req_qual_tbl.last
    Loop
      Dbms_Output.Put_Line('Row index: '||i);
      Dbms_Output.Put_Line('line_index: '||x_req_qual_tbl(I).line_index);
      Dbms_Output.Put_Line(' qual context: '||x_req_qual_tbl(I).qualifier_context);
      Dbms_Output.Put_Line(' qual attr: '||x_req_qual_tbl(I).qualifier_attribute);
      Dbms_Output.Put_Line(' qual attr value from: '||x_req_qual_tbl(I).qualifier_attr_value_from);
      Dbms_Output.Put_Line(' qual attr value to: '||x_req_qual_tbl(I).qualifier_attr_value_to);
      Dbms_Output.Put_Line(' comp opn code: '||x_req_qual_tbl(I).comparison_operator_code);
      Dbms_Output.Put_Line(' validated flag: '||x_req_qual_tbl(I).validated_flag);
      Dbms_Output.Put_Line(' status code: '||x_req_qual_tbl(I).status_code);
      Dbms_Output.Put_Line(' status text: '||x_req_qual_tbl(I).status_text);
    End Loop;
  End If;

  If nvl(x_Req_line_attr_tbl.count,0 ) > 0 Then
    Dbms_Output.Put_Line('-------------Line Attr Information-------------------');
    For i in x_Req_line_attr_tbl.first .. x_Req_line_attr_tbl.last
    Loop
      Dbms_Output.Put_Line('Row index: '||i);
      Dbms_Output.Put_Line('line_index: '||x_Req_line_attr_tbl(I).line_index);
      Dbms_Output.Put_Line(' Prc context: '||x_Req_line_attr_tbl(I).pricing_context);
      Dbms_Output.Put_Line(' Prc attr: '||x_Req_line_attr_tbl(I).pricing_attribute);
      Dbms_Output.Put_Line(' Prc attr value from: '||x_Req_line_attr_tbl(I).pricing_attr_value_from);
      Dbms_Output.Put_Line(' Prc attr value to: '||x_Req_line_attr_tbl(I).pricing_attr_value_to);
      Dbms_Output.Put_Line(' validated flag: '||x_Req_line_attr_tbl(I).validated_flag);
      Dbms_Output.Put_Line(' status code: '||x_Req_line_attr_tbl(I).status_code);
      Dbms_Output.Put_Line(' status text: '||x_Req_line_attr_tbl(I).status_text);
    End Loop;
  End If;

  If nvl(x_req_line_detail_tbl.count,0)  > 0 Then
    Dbms_Output.Put_Line('------------Line Detail Information------------ ');
    For I in x_req_line_detail_tbl.first .. x_req_line_detail_tbl.last
    Loop
      Dbms_Output.Put_Line('Row index: '||i);
      Dbms_Output.Put_Line('line_detail_index: '||x_req_line_detail_tbl(I).line_detail_index);
      Dbms_Output.Put_Line(' line detail type:'||x_req_line_detail_tbl(I).line_detail_type_code);
      Dbms_Output.Put_Line(' line_index: '||x_req_line_detail_tbl(I).line_index);
      Dbms_Output.Put_Line(' list_header_id: '||x_req_line_detail_tbl(I).list_header_id);
      Dbms_Output.Put_Line(' list_line_id: '||x_req_line_detail_tbl(I).list_line_id);
      Dbms_Output.Put_Line(' list_line_type_code: '||x_req_line_detail_tbl(I).list_line_type_code);
      Dbms_Output.Put_Line(' Adjustment Amount : '||x_req_line_detail_tbl(I).adjustment_amount);
      Dbms_Output.Put_Line(' Line Quantity : '||x_req_line_detail_tbl(I).line_quantity);
      Dbms_Output.Put_Line(' List Price : '||x_req_line_detail_tbl(I).list_price);
      Dbms_Output.Put_Line(' Operand_calculation_code: '||x_req_line_detail_tbl(I).Operand_calculation_code);
      Dbms_Output.Put_Line(' Operand value: '||x_req_line_detail_tbl(I).operand_value);
      Dbms_Output.Put_Line(' Automatic Flag: '||x_req_line_detail_tbl(I).automatic_flag);
      Dbms_Output.Put_Line(' Overide Flag: '||x_req_line_detail_tbl(I).override_flag);
      Dbms_Output.Put_Line(' status_code: '||x_req_line_detail_tbl(I).status_code);
      Dbms_Output.Put_Line(' status text: '||x_req_line_detail_tbl(I).status_text);
      Dbms_Output.Put_Line('-------------------------------------------');
    End Loop;
  End If;

  If nvl(x_req_related_lines_tbl.count,0) > 0 Then
    Dbms_Output.Put_Line('--------------Related Lines Information---------------');
    For i in x_req_related_lines_tbl.first .. x_req_related_lines_tbl.last
    Loop
      Dbms_Output.Put_Line('Row index: '||i);
      Dbms_Output.Put_Line('Line Index :'||x_req_related_lines_tbl(I).line_index);
      Dbms_Output.Put_Line('Line detail index: '||x_req_related_lines_tbl(I).LINE_DETAIL_INDEX);
      Dbms_Output.Put_Line(' Relationship type code: '||x_req_related_lines_tbl(I).relationship_type_code);
      Dbms_Output.Put_Line(' Related Line Index: '||x_req_related_lines_tbl(I).RELATED_LINE_INDEX);
      Dbms_Output.Put_Line(' Related line detail index: '||x_req_related_lines_tbl(I).related_line_detail_index);
      Dbms_Output.Put_Line(' Status Code: '|| x_req_related_lines_tbl(I).STATUS_CODE);
    End Loop;
  End If;

  If nvl(x_req_line_detail_attr_tbl.count,0) > 0 Then
    Dbms_Output.Put_Line('-----------Attributes Information-------------');
    For i in x_req_line_detail_attr_tbl.first .. x_req_line_detail_attr_tbl.last
    Loop
      Dbms_Output.Put_Line('Row index: '||i);
      Dbms_Output.Put_Line('Line detail INDEX '||x_req_line_detail_attr_tbl(I).line_detail_index);
      Dbms_Output.Put_Line(' Pricing Context '||x_req_line_detail_attr_tbl(I).pricing_context);
      Dbms_Output.Put_Line(' Pricing attribute '||x_req_line_detail_attr_tbl(I).pricing_attribute);
      Dbms_Output.Put_Line(' Pricing attr value from '||x_req_line_detail_attr_tbl(I).pricing_attr_value_from);
      Dbms_Output.Put_Line(' Pircing attr value to '||x_req_line_detail_attr_tbl(I).pricing_attr_value_to);
      Dbms_Output.Put_Line(' Status Code '||x_req_line_detail_attr_tbl(I).status_code);
    End Loop;
  End If;

  If nvl(x_req_line_detail_qual_tbl.count,0) > 0 Then
    Dbms_Output.Put_Line('-----------Qualifier Attributes Information-------------');
    For i in x_req_line_detail_qual_tbl.first .. x_req_line_detail_qual_tbl.last
    Loop
      Dbms_Output.Put_Line('Row index: '||i);
      Dbms_Output.Put_Line('Line detail INDEX '||x_req_line_detail_qual_tbl(I).line_detail_index);
      Dbms_Output.Put_Line(' Qualifier Context '||x_req_line_detail_qual_tbl(I).qualifier_context);
      Dbms_Output.Put_Line(' Qualifier attribute '||x_req_line_detail_qual_tbl(I).qualifier_attribute);
      Dbms_Output.Put_Line(' Qualifier attr value from '||x_req_line_detail_qual_tbl(I).qualifier_attr_value_from);
      Dbms_Output.Put_Line(' Qualifier attr value to '||x_req_line_detail_qual_tbl(I).qualifier_attr_value_to);
      Dbms_Output.Put_Line(' Status Code '||x_req_line_detail_qual_tbl(I).status_code);
      Dbms_Output.Put_Line('---------------------------------------------------');
    End Loop;
  End If;
  Dbms_Output.Put_Line('+--------------------------------------------------------------+'); */

EXCEPTION
  WHEN FND_API.G_EXC_ERROR Then
    x_return_status := OKC_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR Then
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS Then
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    -- Dbms_Output.Put_Line('Error is '|| sqlerrm);
    If FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) Then
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,
                              'OKC_PRICE_PUB.CALL_PRICE_ENGINE',
                              sqlerrm);
    End If;
END Call_QP;
--
/**** For calculate_Price do we need the caller to fill up the contract_cp_tbl too?
Do we need the contract_cp_tbl?? It should have the same info as the line_rec ??
=== This api is called from ANOTHER calculat_Prcie API which sets the reqd info
properly =====***/

Procedure Calculate_Price(p_contract_line_rec  IN OKC_PRICE_PUB.G_LINE_REC_TYPE,
                          px_contract_cp_tbl   IN OUT NOCOPY OKC_PRICE_PUB.G_SLINE_TBL_TYPE,
					 px_message           OUT NOCOPY VARCHAR2,
                          x_return_status      OUT NOCOPY VARCHAR2,
                          x_msg_count          OUT NOCOPY NUMBER,
                          x_msg_data           OUT NOCOPY VARCHAR2) IS
  l_return_status                 Varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
  l_return_status_text            Varchar2(240) := NULL;
  lx_req_line_tbl                 QP_PREQ_GRP.LINE_TBL_TYPE;
  lx_Req_qual_tbl                 QP_PREQ_GRP.QUAL_TBL_TYPE;
  lx_Req_line_attr_tbl            QP_PREQ_GRP.LINE_ATTR_TBL_TYPE;
  lx_Req_LINE_DETAIL_tbl          QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE;
  lx_Req_LINE_DETAIL_qual_tbl     QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE;
  lx_Req_LINE_DETAIL_attr_tbl     QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE;
  lx_Req_related_lines_tbl        QP_PREQ_GRP.RELATED_LINES_TBL_TYPE;
  l_idx                           NUMBER := 0;
  l_contract_line_rec             OKC_PRICE_PUB.G_LINE_REC_TYPE := p_contract_line_rec;
Begin
  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  If nvl(p_contract_line_rec.record_built_flag, 'Y')  = 'N' Then
    --- Build the contract line record so that it can be used in sourcing pricing attributes
    Build_Okc_Kline_Rec(p_Contract_Line_Id  => p_contract_line_rec.line_id,
   x_CONTRACT_Line_rec  => l_contract_line_rec,
   x_return_status   => l_return_status);
    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
      Raise G_BUILD_RECORD_FAILED;
    End If;
  Else
    l_contract_line_rec := p_contract_line_rec;
  End If;

  If l_contract_line_rec.price_list_id is null Or
    l_contract_line_rec.inventory_item_id is null Or
    l_contract_line_rec.item_qty is null Or
    l_contract_line_rec.item_uom_code is null Or
    -- l_contract_line_rec.start_date is null Or
    l_contract_line_rec.currency_code is null Then
    Raise G_REQUIRED_ATTR_FAILED;
  End If;
  -- Dbms_Output.Put_Line('Before Call_Qp');
  Call_QP(p_contract_line_rec        => l_contract_line_rec,
          p_contract_cp_tbl          => px_contract_cp_tbl,
          p_get_pb_tbl_flag          => 'N',
          x_Req_line_tbl             => lx_req_line_tbl,
          x_Req_qual_tbl             => lx_Req_qual_tbl,
          x_Req_line_attr_tbl        => lx_Req_line_attr_tbl,
          x_Req_line_detail_tbl      => lx_req_line_detail_tbl,
          x_Req_line_detail_qual_tbl => lx_req_line_detail_qual_tbl,
          x_Req_line_detail_attr_tbl => lx_req_line_detail_attr_tbl,
          x_Req_related_lines_tbl    => lx_req_related_lines_tbl,
          x_return_status            => l_return_status,
          x_return_status_text       => l_return_status_text);
  -- Dbms_Output.Put_Line('After Call_Qp');
  -- Dbms_Output.Put_Line('Return Status text : '|| l_return_status || ' : ' || l_return_status_text);

  If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
    -- Dbms_Output.Put_Line('Qp Engine Failed !!');
    Raise G_CALL_QP_FAILED;
  End If;
  -- Dbms_Output.Put_Line('Qp Engine Success !!');

  --- Change is needed For priced qty/uom when qp is ready with uom conversion
  If nvl(l_contract_line_rec.usage_item_flag, 'N') = 'N' Then
    For i In px_contract_cp_tbl.first .. px_contract_cp_tbl.last
    Loop
      l_idx := i;
      -- l_idx := i * 2;
      px_contract_cp_tbl(i).priced_quantity := lx_req_line_tbl(l_idx).priced_quantity;
      px_contract_cp_tbl(i).priced_uom_code := lx_req_line_tbl(l_idx).priced_uom_code;
      -- px_contract_cp_tbl(i).priced_quantity := lx_req_line_tbl(l_idx).priced_quantity;
      -- px_contract_cp_tbl(i).priced_uom_code := lx_req_line_tbl(l_idx).priced_uom_code;
      px_contract_cp_tbl(i).currency_code := lx_req_line_tbl(l_idx).currency_code;
      -- px_contract_cp_tbl(i).unit_price := lx_req_line_tbl(l_idx).unit_price;
      px_contract_cp_tbl(i).unit_price := lx_req_line_tbl(l_idx).unit_price *
								  (lx_req_line_tbl(l_idx).priced_quantity /
								   px_contract_cp_tbl(i).item_qty);
      px_contract_cp_tbl(i).adjusted_unit_price := lx_req_line_tbl(l_idx).adjusted_unit_price;
      px_contract_cp_tbl(i).cp_unit_price := lx_req_line_tbl(l_idx).parent_price;

      -- Not yet ready for OKC. percent_price will not be used.
      If nvl(lx_req_line_tbl(l_idx).percent_price,0) > 0 Then
        px_contract_cp_tbl(i).unit_percent  := lx_req_line_tbl(l_idx).percent_price;
        px_contract_cp_tbl(i).extended_amount := (lx_req_line_tbl(l_idx).percent_price *
                                                  lx_req_line_tbl(l_idx).parent_price) / 100.0 *
                                                  lx_req_line_tbl(l_idx).line_quantity *
	                                             lx_req_line_tbl(l_idx).priced_quantity;
                                                  -- px_contract_cp_tbl(i).item_qty;
      Else
        -- Commented out the following, used mainly for Service contracts
        /* px_contract_cp_tbl(i).extended_amount := lx_req_line_tbl(l_idx).unit_price *
                                                 lx_req_line_tbl(l_idx).line_quantity *
	                                         px_contract_cp_tbl(i).item_qty; */
        px_contract_cp_tbl(i).extended_amount := lx_req_line_tbl(l_idx).unit_price *
	                                         lx_req_line_tbl(l_idx).priced_quantity;
	                                         -- px_contract_cp_tbl(i).item_qty;
      End If;
	 px_message := lx_req_line_tbl(l_idx).status_text;
    End Loop;
  Else
    -- Used for Service contracts
    For i In px_contract_cp_tbl.first .. px_contract_cp_tbl.last
    Loop
      --- this part needs to be worked out
      px_contract_cp_tbl(i).unit_price  := lx_req_line_tbl(i).unit_price;
      px_contract_cp_tbl(i).unit_percent  := lx_req_line_tbl(i).percent_price;
      px_contract_cp_tbl(i).priced_quantity  := lx_req_line_tbl(i).priced_quantity;
      px_contract_cp_tbl(i).priced_uom_code  := lx_req_line_tbl(i).priced_uom_code;
      px_contract_cp_tbl(i).currency_code  := lx_req_line_tbl(i).currency_code;
      px_contract_cp_tbl(i).adjusted_unit_price  := lx_req_line_tbl(i).adjusted_unit_price;
      px_contract_cp_tbl(i).extended_amount  := px_contract_cp_tbl(i).adjusted_unit_price *
                                                px_contract_cp_tbl(i).item_qty;
    End Loop;
  End If;
EXCEPTION
  When G_BUILD_RECORD_FAILED Then
    x_return_status := OKC_API.G_RET_STS_ERROR;
    If FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) Then
      FND_MESSAGE.SET_NAME('OKC','OKC_DATA_NOT_POSTED');
      FND_MSG_PUB.Add;
    End If;
    FND_MSG_PUB.COUNT_AND_GET(p_count => x_msg_count,
                              p_data => x_msg_data,
                              p_encoded => FND_API.G_FALSE);
  When G_REQUIRED_ATTR_FAILED Then
    x_return_status := OKC_API.G_RET_STS_ERROR;
    If FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) Then
      FND_MESSAGE.SET_NAME('OKC','OKC_ITEM_UOM_QTY_NUMM');
      FND_MSG_PUB.Add;
    End If;
    FND_MSG_PUB.COUNT_AND_GET(p_count  => x_msg_count,
                              p_data   => x_msg_data,
                              p_encoded  => FND_API.G_FALSE);
  When  G_CALL_QP_FAILED Then
    x_return_status := OKC_API.G_RET_STS_ERROR;
    If FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) Then
      FND_MESSAGE.SET_NAME('OKC','OKC_QP_FAILED');
      FND_MSG_PUB.Add;
    End If;
    FND_MSG_PUB.COUNT_AND_GET(p_count  => x_msg_count,
                              p_data   => x_msg_data,
                              p_encoded  => FND_API.G_FALSE);

  When G_EXCEPTION_HALT_VALIDATION Then
    x_return_status   :=   OKC_API.G_RET_STS_UNEXP_ERROR;
    OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR, G_SQLCODE_TOKEN,
				    SQLCODE, G_SQLERRM_TOKEN,SQLERRM);
  When FND_API.G_EXC_ERROR Then
    x_return_status := OKC_API.G_RET_STS_ERROR;
  When FND_API.G_EXC_UNEXPECTED_ERROR Then
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  When OTHERS Then
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR, G_SQLCODE_TOKEN,
				    SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
End Calculate_Price;
--

/*** For OKC we need to call this API..... ***/

Procedure Calculate_Price(p_clev_tbl          OKC_CONTRACT_PUB.clev_tbl_type,
                          p_cimv_tbl          OKC_CONTRACT_ITEM_PUB.cimv_tbl_type,
					 px_message          OUT NOCOPY VARCHAR2,
                          px_contract_cp_tbl  IN OUT NOCOPY OKC_PRICE_PUB.G_SLINE_TBL_TYPE,
                          x_return_status     OUT NOCOPY VARCHAR2,
                          x_msg_count         OUT NOCOPY NUMBER,
                          x_msg_data          OUT NOCOPY VARCHAR2) IS
  l_contract_line_rec             OKC_PRICE_PUB.G_LINE_REC_TYPE;
  l_return_status                 Varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
  l_price_list_id                 Number;
  l_inventory_item_id             Number;
  l_uom_code                      Varchar2(3);
  l_qty                           Number;
  l_cur_code                      Varchar2(15);
  QP_Not_Installed                Exception;
  Mandatory_Data_Missing          Exception;
Begin
  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  --Bug 2752224--Moving after price list check to avoid error
  -- when user intends to enter price manually
  /*If Not Product_Installed('QP') Then
    Raise QP_Not_Installed;
  End If;
  */
  Get_Price_List(p_clev_tbl,
                 l_price_list_id,
                 l_return_status);
  If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
    Raise Mandatory_Data_Missing;
  Else
    if l_price_list_id Is Null Then
	 -- It is success. Either there is no Pricing Rule attached or
	 -- NOLOV Price List is attached to the Rule. These 2 should
	 -- not be reported as error.
      Raise Mandatory_Data_Missing;
    End If;
  End If;

   --Check for QP installation after checking for price list
  If Not Product_Installed('QP') Then
      Raise QP_Not_Installed;
  End If;

  Get_Inventory_Item(p_clev_tbl,
                     p_cimv_tbl,
                     l_inventory_item_id,
                     l_uom_code,
                     l_qty,
                     l_return_status);
  If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
    Raise Mandatory_Data_Missing;
  End If;
  Get_Currency_Code(p_clev_tbl,
                    l_cur_code,
                    l_return_status);
  If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
    Raise Mandatory_Data_Missing;
  End If;
  /* dbms_output.put_line('line_id ' || p_cle_id);
  dbms_output.put_line('price_list_id ' || l_price_list_id);
  dbms_output.put_line('inventory_item_id ' || l_inventory_item_id);
  dbms_output.put_line('item_qty ' || l_qty);
  dbms_output.put_line('item_uom_code ' || l_uom_code);
  dbms_output.put_line('currency_code ' || l_cur_code); */
  If p_clev_tbl(1).id Is Not Null Then
    l_contract_line_rec.line_id := p_clev_tbl(1).id;
  End If;
  l_contract_line_rec.price_list_id := l_price_list_id;
  l_contract_line_rec.inventory_item_id := l_inventory_item_id;
  l_contract_line_rec.item_qty := l_qty;
  l_contract_line_rec.item_uom_code := l_uom_code;
  l_contract_line_rec.currency_code := l_cur_code;
  l_contract_line_rec.usage_item_flag := 'N';
  l_contract_line_rec.record_built_flag := 'Y';

  px_contract_cp_tbl(1).inventory_item_id := l_inventory_item_id;
  px_contract_cp_tbl(1).item_qty := l_qty;
  px_contract_cp_tbl(1).item_uom_code := l_uom_code;
  px_contract_cp_tbl(1).currency_code := l_cur_code;

/*** The line_rec and contract_cp_tbl contain the same info ***/
  Calculate_Price(l_contract_line_rec,
                  px_contract_cp_tbl,
                  px_message,
                  x_return_status,
                  x_msg_count,
                  x_msg_data);
EXCEPTION
  When QP_Not_Installed Then
    -- dbms_output.put_line('QP_NOT_INSTALLED');
    x_return_status := OKC_API.G_RET_STS_ERROR;
  When Mandatory_Data_Missing Then
    -- dbms_output.put_line('Mandatory_Data_Missing');
    x_return_status := l_return_status;
  When OTHERS Then
    -- dbms_output.put_line('Unexpected Errors');
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR, G_SQLCODE_TOKEN,
				    SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
End Calculate_Price;
--
Procedure Calculate_Price(p_clev_tbl          OKC_CONTRACT_PUB.clev_tbl_type,
                          p_cimv_tbl          OKC_CONTRACT_ITEM_PUB.cimv_tbl_type,
                          px_unit_price       OUT NOCOPY Number,
                          px_extended_amount  OUT NOCOPY Number,
                          px_message          OUT NOCOPY Varchar2,
                          x_return_status     OUT NOCOPY VARCHAR2,
                          x_msg_count         OUT NOCOPY NUMBER,
                          x_msg_data          OUT NOCOPY VARCHAR2) IS
  l_return_status         Varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
  l_contract_cp_tbl       G_SLINE_TBL_TYPE;
  Data_Unposted           Exception;
Begin
  OKC_API.init_msg_list(OKC_API.G_FALSE);
  If (p_clev_tbl.COUNT = 0) Or
     (p_cimv_tbl.COUNT = 0) Then
    Raise Data_Unposted;
  End If;
  Calculate_Price(p_clev_tbl,
                  p_cimv_tbl,
			   px_message,
                  l_contract_cp_tbl,
                  l_return_status,
                  x_msg_count,
                  x_msg_data);
  x_return_status := l_return_status;
  If l_return_status = OKC_API.G_RET_STS_SUCCESS Then
    If l_contract_cp_tbl.count > 0 Then
      px_unit_price := l_contract_cp_tbl(1).unit_price;
      px_extended_amount := l_contract_cp_tbl(1).extended_amount;
    End If;
  End If;
EXCEPTION
  When Data_Unposted Then
    x_return_status := OKC_API.G_RET_STS_ERROR;
    OKC_API.set_message(G_APP_NAME, 'OKC_DATA_NOT_POSTED');
  When OTHERS Then
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR, G_SQLCODE_TOKEN,
				    SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
End Calculate_Price;
--
-- ifilimon: added to support unit price retrieving by main item attributes
FUNCTION Get_Unit_Price(
  p_price_list_id                 Number,
  p_inventory_item_id             Number,
  p_uom_code                      Varchar2,
  p_cur_code                      Varchar2,
  p_qty                           NUMBER := 1
) RETURN NUMBER IS
  l_contract_cp_tbl               OKC_PRICE_PUB.G_SLINE_TBL_TYPE;
  l_contract_line_rec             OKC_PRICE_PUB.G_LINE_REC_TYPE;
  x_return_status                 Varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
  x_message  VARCHAR2(1000);
  x_msg_count				NUMBER;
  x_msg_data				VARCHAR2(2000);
 BEGIN
  l_contract_line_rec.price_list_id := p_price_list_id;
  l_contract_line_rec.inventory_item_id := p_inventory_item_id;
  l_contract_line_rec.item_uom_code := p_uom_code;
  l_contract_line_rec.currency_code := p_cur_code;

  l_contract_line_rec.item_qty := p_qty;
  l_contract_line_rec.usage_item_flag := 'N';
  l_contract_line_rec.record_built_flag := 'Y';

  l_contract_cp_tbl(1).inventory_item_id := l_contract_line_rec.inventory_item_id;
  l_contract_cp_tbl(1).item_qty := l_contract_line_rec.item_qty;
  l_contract_cp_tbl(1).item_uom_code := l_contract_line_rec.item_uom_code;
  l_contract_cp_tbl(1).currency_code := l_contract_line_rec.currency_code;

/*** The line_rec and contract_cp_tbl contain the same info ***/
  Calculate_Price(l_contract_line_rec,
                  l_contract_cp_tbl,
                  x_message,
                  x_return_status,
                  x_msg_count,
                  x_msg_data);
  IF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
    return l_contract_cp_tbl(1).unit_price;
   ELSE
    return NULL;
  END IF;
 EXCEPTION
  WHEN OTHERS THEN
   return NULL;
END;
--
Procedure GET_PRICE_BREAK(
 p_contract_line_rec  IN OKC_PRICE_PUB.G_LINE_REC_TYPE,
 x_price_break_tbl   OUT NOCOPY OKC_PRICE_PUB.G_PRICE_BREAK_TBL_TYPE,
 x_return_status   OUT NOCOPY VARCHAR2,
 x_msg_count   OUT NOCOPY NUMBER,
 x_msg_data   OUT NOCOPY VARCHAR2)
IS

 l_contract_line_rec  OKC_PRICE_PUB.G_LINE_REC_TYPE;

 ---- dummy table
 l_contract_cp_tbl   OKC_PRICE_PUB.G_SLINE_TBL_TYPE;
 l_return_status    varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
 l_return_status_text   varchar2(240) := NULL;

 lx_req_line_tbl                 QP_PREQ_GRP.LINE_TBL_TYPE;
 lx_Req_qual_tbl                 QP_PREQ_GRP.QUAL_TBL_TYPE;
 lx_Req_line_attr_tbl            QP_PREQ_GRP.LINE_ATTR_TBL_TYPE;
 lx_Req_LINE_DETAIL_tbl          QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE;
 lx_Req_LINE_DETAIL_qual_tbl     QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE;
 lx_Req_LINE_DETAIL_attr_tbl     QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE;
 lx_Req_related_lines_tbl        QP_PREQ_GRP.RELATED_LINES_TBL_TYPE;
 l_price_break_tbl  OKC_PRICE_PUB.G_PRICE_BREAK_TBL_TYPE;
 l_rel_index   NUMBER;

 CURSOR puom_cur(p_inv_id NUMBER) IS
  select primary_uom_code from OKX_SYSTEM_ITEMS_V
  WHERE  ID1 = p_inv_id;
BEGIN
       x_return_status   :=  OKC_API.G_RET_STS_SUCCESS;

 If nvl(p_contract_line_rec.record_built_flag, 'Y')  = 'N' Then
  --- Build the contract line record so that it can be used in sourcing pricing attributes
  BUILD_OKC_KLINE_REC(
   p_Contract_Line_Id  => p_contract_line_rec.line_id,
   x_CONTRACT_Line_rec  => l_contract_line_rec,
   x_return_status   => l_return_status);
  ----Dbms_Output.Put_Line('RETURN STATUS ' || l_return_status);
  If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
          RAISE G_BUILD_RECORD_FAILED;
  End If;
 Else
  l_contract_line_rec := p_contract_line_rec;
 End If;

 -- Just to get price break, hard-code quantity to 1 and UOM to primary uom of the item
 l_contract_line_rec.item_qty := 1;

 OPEN puom_cur(l_contract_line_rec.inventory_item_id);
 FETCH puom_cur INTO l_contract_line_rec.item_uom_code;
 CLOSE puom_cur;

 If l_contract_line_rec.price_list_id is null Or
  l_contract_line_rec.inventory_item_id is null Or
  l_contract_line_rec.item_qty is null Or
  l_contract_line_rec.item_uom_code is null Or
  l_contract_line_rec.start_date is null Or
  l_contract_line_rec.currency_code is null  Then
  RAISE G_REQUIRED_ATTR_FAILED;
 End If;
 ----Dbms_Output.Put_Line ('Before Calling QP');
 CALL_QP(
  p_contract_line_rec  => l_contract_line_rec,
  p_contract_cp_tbl   => l_contract_cp_tbl,
  p_get_pb_tbl_flag  => 'Y',
    x_Req_line_tbl               => lx_req_line_tbl,
     x_Req_qual_tbl               => lx_Req_qual_tbl,
      x_Req_line_attr_tbl          => lx_Req_line_attr_tbl,
  x_Req_line_detail_tbl        => lx_req_line_detail_tbl,
  x_Req_line_detail_qual_tbl   => lx_req_line_detail_qual_tbl,
  x_Req_line_detail_attr_tbl   => lx_req_line_detail_attr_tbl,
  x_Req_related_lines_tbl      => lx_req_related_lines_tbl,
  x_return_status   => l_return_status,
  x_return_status_text  => l_return_status_text);

 If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
         RAISE G_CALL_QP_FAILED;
 End If;

 For i in lx_req_related_lines_tbl.first .. lx_req_related_lines_tbl.last
 Loop
  If lx_req_related_lines_tbl(i).relationship_type_code = QP_PREQ_GRP.G_PBH_LINE Then
   l_rel_index := lx_req_related_lines_tbl(i).related_line_detail_index;
  ---Dbms_Output.Put_Line('REL INDEX ' || l_rel_index);
  For j in lx_req_line_detail_attr_tbl.first .. lx_req_line_detail_attr_tbl.last
  Loop
   If lx_req_line_detail_attr_tbl(j).line_detail_index = l_rel_index Then
   ---Dbms_Output.Put_Line('LINE DETAIL INDEX ' || lx_req_line_detail_attr_tbl(j).line_detail_index);
    l_price_break_tbl(i).quantity_from  :=
     lx_req_line_detail_attr_tbl(j).PRICING_ATTR_VALUE_FROM  ;
    l_price_break_tbl(i).quantity_to  :=
     lx_req_line_detail_attr_tbl(j).PRICING_ATTR_VALUE_TO  ;
   End If;
  End Loop;
  For y in lx_req_line_detail_tbl.first .. lx_req_line_detail_tbl.last
  Loop
   If lx_req_line_detail_tbl(y).line_detail_index = l_rel_index Then
    l_price_break_tbl(i).list_price  :=
     lx_req_line_detail_tbl(y).list_price;
    l_price_break_tbl(i).break_method :=
     lx_req_line_detail_tbl(y).price_break_type_code;
   End If;
  End Loop;

  --Dbms_Output.Put_Line(l_price_break_tbl(i).quantity_from  || ' - ' ||
   --l_price_break_tbl(i).quantity_to || ' - ' ||
     --l_price_break_tbl(i).list_price || ' - ' ||
     --l_price_break_tbl(i).break_method);
  End If;
 End Loop;
 x_price_break_tbl := l_price_break_tbl;
EXCEPTION
 WHEN  G_BUILD_RECORD_FAILED Then
     x_return_status := OKC_API.G_RET_STS_ERROR;
  If FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
  Then
      FND_MESSAGE.SET_NAME('OKC','OKC_DATA_NOT_POSTED');
      FND_MSG_PUB.Add;
  End If;

  FND_MSG_PUB.COUNT_AND_GET(
   p_count  => x_msg_count,
   p_data   => x_msg_data,
   p_encoded  => FND_API.G_FALSE);

 WHEN G_REQUIRED_ATTR_FAILED Then
     x_return_status := OKC_API.G_RET_STS_ERROR;
  If FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
  Then
      FND_MESSAGE.SET_NAME('OKC','OKC_ITEM_UOM_QTY_NULL');
      FND_MSG_PUB.Add;
  End If;

  FND_MSG_PUB.COUNT_AND_GET(
   p_count  => x_msg_count,
   p_data   => x_msg_data,
   p_encoded  => FND_API.G_FALSE);

 WHEN  G_CALL_QP_FAILED Then
     x_return_status := OKC_API.G_RET_STS_ERROR;
  If FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
  Then
      FND_MESSAGE.SET_NAME('OKC','OKC_QP_FAILED');
      FND_MSG_PUB.Add;
  End If;

  FND_MSG_PUB.COUNT_AND_GET(
   p_count  => x_msg_count,
   p_data   => x_msg_data,
   p_encoded  => FND_API.G_FALSE);

 WHEN  G_EXCEPTION_HALT_VALIDATION Then
            x_return_status   :=   OKC_API.G_RET_STS_UNEXP_ERROR;
            OKC_API.set_message(G_APP_NAME,G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN,SQLERRM);
 WHEN FND_API.G_EXC_ERROR Then
  x_return_status := OKC_API.G_RET_STS_ERROR;
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR Then
  x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
 WHEN  OTHERS Then
              x_return_status   :=   OKC_API.G_RET_STS_UNEXP_ERROR;
              OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);

END GET_PRICE_BREAK;

/*--------Begin Added by Jomy--------*/
Procedure Get_Customer_Info(p_cust_id NUMBER)
	IS
	v_count               NUMBER := 1;
	l_temp_tbl       QP_Attr_Mapping_PUB.t_MultiRecord;
	i           pls_integer;
BEGIN
	G_Customer_Info.customer_id := p_cust_id;
--  Getting info from OKX_CUSTOMER_ACCOUNTS_V
    BEGIN
        SELECT customer_class_code,
               sales_channel_code,
               gsa_indicator
        INTO   G_Customer_Info.customer_class_code,
               G_Customer_Info.sales_channel_code,
               G_Customer_Info.gsa_indicator
---FROM   ra_customers
	FROM  OKX_CUSTOMER_ACCOUNTS_V
        WHERE ID1 = p_cust_id;
---        WHERE CUST_ACCOUNT_ID = p_cust_id;
---FROM RA_customers
---     WHERE customer_id = p_cust_id;
        EXCEPTION
                WHEN no_data_found THEN
                        G_Customer_Info.customer_class_code := null;
                        G_Customer_Info.sales_channel_code := null;
                        G_Customer_Info.gsa_indicator := null;
    END;
-- Getting Account Types
     Begin
--------SELECT distinct customer_profile_class_id
	SELECT distinct PROFILE_CLASS_ID
           BULK COLLECT INTO l_temp_tbl
	FROM   OKX_CUSTOMER_PROFILES_V
        WHERE  	cust_account_id = p_cust_id;
--------FROM   AR_CUSTOMER_PROFILES
--------WHERE  	customer_id = p_cust_id;

        i:= l_temp_tbl.first;
        While i is not null
        LOOP
            G_Customer_Info.account_types(v_count) := l_temp_tbl(i);
            v_count := v_count + 1;
            i:=l_temp_tbl.next(i);
        END LOOP;
        EXCEPTION
          When others then
             null;
     END;
--  Get Customer Relationships
        l_temp_tbl.delete;
        v_count := 1;
   BEGIN
-- SELECT RELATED_CUSTOMER_ID
   SELECT ID1
	BULK COLLECT INTO l_temp_tbl
	FROM   OKX_CUST_ACCT_RELATE_V
    WHERE  customer_id = p_cust_id;
---FROM   RA_CUSTOMER_RELATIONSHIPS
---WHERE  customer_id = p_cust_id;
	i:= l_temp_tbl.first;
    While i is not null
     LOOP
          G_Customer_Info.customer_relationships(v_count) := l_temp_tbl(i);
          v_count := v_count + 1;
          i:=l_temp_tbl.next(i);
     END LOOP;
     EXCEPTION
          When others then
             null;
   END;
END Get_Customer_Info;

FUNCTION Get_Item_Category
	(
	   p_inventory_item_id IN NUMBER,
	   p_org_id IN NUMBER
	)
	RETURN QP_Attr_Mapping_PUB.t_MultiRecord
	IS

	x_category_ids     QP_Attr_Mapping_PUB.t_MultiRecord;

BEGIN
--  Bug 2304008 skekkar
SELECT ic.id1
     BULK COLLECT
INTO x_category_ids
FROM   OKX_ITEM_CATEGORIES_V  ic,
       MTL_CATEGORIES_B c,
       FND_ID_FLEX_STRUCTURES fs
WHERE  c.category_id = ic.category_id
  AND  c.structure_id = fs.id_flex_num
  AND  fs.id_flex_structure_code = 'ITEM_CATEGORIES'
  AND  ic.inventory_item_id = p_inventory_item_id
  AND  ic.organization_id = p_org_id;

/*
  SELECT ID1
         BULK COLLECT
         INTO x_category_ids
  FROM   OKX_ITEM_CATEGORIES_V
  WHERE  inventory_item_id = p_inventory_item_id
  AND    organization_id = p_org_id;
*/
/********************************************************
--SELECT category_id BULK COLLECT INTO x_category_ids
	FROM   mtl_item_categories
--WHERE  inventory_item_id = p_inventory_item_id
--AND    organization_id = p_org_id;
*********************************************************/
	RETURN x_category_ids;

END Get_Item_Category;
---******************************
FUNCTION Get_Customer_Class(p_cust_id IN NUMBER) RETURN VARCHAR2
IS

BEGIN
	IF G_Customer_Info.customer_id = p_cust_id then
         return G_Customer_Info.customer_class_code;
     ELSE
         Get_Customer_Info(p_cust_id);
         return G_Customer_Info.customer_class_code;
     END IF;
END Get_Customer_Class;
---***-- END Get_Customer_Class ---************************
FUNCTION Get_Account_Type (p_cust_id IN NUMBER) RETURN QP_Attr_Mapping_PUB.t_MultiRecord
IS
BEGIN
	IF p_cust_id = G_Customer_Info.customer_id THEN
	   RETURN G_Customer_Info.account_types;
	ELSE
	   Get_Customer_Info(p_cust_id);
	   RETURN G_Customer_Info.account_types;
     END IF;
END Get_Account_Type;
---***-- END Get_Account_Type ---************************

FUNCTION Get_Sales_Channel (p_cust_id IN NUMBER) RETURN VARCHAR2
IS
BEGIN
	IF G_Customer_Info.customer_id = p_cust_id then
            return G_Customer_Info.sales_channel_code;
     ELSE
            Get_Customer_Info(p_cust_id);
            return G_Customer_Info.sales_channel_code;
     END IF;
END Get_Sales_Channel;
---***-- END Get_Sales_Channel ---************************
FUNCTION Get_GSA (p_cust_id NUMBER) RETURN VARCHAR2
IS
BEGIN
        IF G_Customer_Info.customer_id = p_cust_id then
                return G_Customer_Info.gsa_indicator;
        ELSE
                Get_Customer_Info(p_cust_id);
                return G_Customer_Info.gsa_indicator;
        END IF;
END Get_GSA;
---***-- END Get_GSA ---************************
PROCEDURE Get_Item_Segments_All(p_inventory_item_id IN NUMBER, p_org_id IN NUMBER
)
IS
BEGIN
	G_Item_Segments.inventory_item_id := p_inventory_item_id;

  SELECT  segment1,segment2,segment3,segment4,segment5,
          segment6,segment7,segment8,segment9,segment10,
          segment11,segment12,segment13,segment14,segment15,
          segment16,segment17,segment18,segment19,segment20
  INTO
	  G_Item_Segments.segment1,G_Item_Segments.segment2,G_Item_Segments.segment3,
	  G_Item_Segments.segment4,G_Item_Segments.segment5,G_Item_Segments.segment6,
	  G_Item_Segments.segment7,G_Item_Segments.segment8,G_Item_Segments.segment9,
	  G_Item_Segments.segment10,G_Item_Segments.segment11,G_Item_Segments.segment12,
	  G_Item_Segments.segment13,G_Item_Segments.segment14,G_Item_Segments.segment15,
	  G_Item_Segments.segment16,G_Item_Segments.segment17,G_Item_Segments.segment18,
	  G_Item_Segments.segment19,G_Item_Segments.segment20
  FROM okx_system_items_v
  WHERE   inventory_item_id = p_inventory_item_id
  AND     organization_id = p_org_id;
---FROM    mtl_system_items
---     WHERE   inventory_item_id = p_inventory_item_id
---     AND     organization_id = p_org_id;
END Get_Item_Segments_All;
---******************************
FUNCTION Get_Item_Segment
	( p_inventory_item_id IN NUMBER,
          p_org_id IN NUMBER,
	  p_seg_num NUMBER
	)
	RETURN VARCHAR2
IS
	l_segment_name  VARCHAR2(30);
BEGIN
        IF p_inventory_item_id <>  G_Item_Segments.inventory_item_id THEN
                Get_Item_Segments_All(p_inventory_item_id,p_org_id);
        END IF;
        IF p_seg_num = 1 THEN
                RETURN G_Item_Segments.segment1;
        ELSIF p_seg_num = 2 THEN
                RETURN G_Item_Segments.segment2;
        ELSIF p_seg_num = 3 THEN
                RETURN G_Item_Segments.segment3;
        ELSIF p_seg_num = 4 THEN
                RETURN G_Item_Segments.segment4;
        ELSIF p_seg_num = 5 THEN
                RETURN G_Item_Segments.segment5;
        ELSIF p_seg_num = 6 THEN
                RETURN G_Item_Segments.segment6;
        ELSIF p_seg_num = 7 THEN
                RETURN G_Item_Segments.segment7;
        ELSIF p_seg_num = 8 THEN
                RETURN G_Item_Segments.segment8;
        ELSIF p_seg_num = 9 THEN
                RETURN G_Item_Segments.segment9;
        ELSIF p_seg_num = 10 THEN
                RETURN G_Item_Segments.segment10;
        ELSIF p_seg_num = 11 THEN
                RETURN G_Item_Segments.segment11;
        ELSIF p_seg_num = 12 THEN
                RETURN G_Item_Segments.segment12;
        ELSIF p_seg_num = 13 THEN
                RETURN G_Item_Segments.segment13;
        ELSIF p_seg_num = 14 THEN
                RETURN G_Item_Segments.segment14;
        ELSIF p_seg_num = 15 THEN
                RETURN G_Item_Segments.segment15;
        ELSIF p_seg_num = 16 THEN
                RETURN G_Item_Segments.segment16;
        ELSIF p_seg_num = 17 THEN
                RETURN G_Item_Segments.segment17;
        ELSIF p_seg_num = 18 THEN
                RETURN G_Item_Segments.segment18;
        ELSIF p_seg_num = 19 THEN
                RETURN G_Item_Segments.segment19;
        ELSIF p_seg_num = 20 THEN
                RETURN G_Item_Segments.segment20;
        END IF;
END Get_Item_Segment;
---******************************
/*End Added by Jomy*/
-----attribute mapping functions added by smhanda-------------------------------

FUNCTION Get_Site_Use (p_rul_tbl IN GLOBAL_RPRLE_TBL_TYPE) RETURN QP_Attr_Mapping_PUB.t_MultiRecord
IS

x_site_use_info	QP_Attr_Mapping_PUB.t_MultiRecord;
l_ship_to_org_id  number :=null;
l_invoice_to_org_id number :=null;
i    pls_integer :=0;
BEGIN
     i:=p_rul_tbl.first;
     While i is not null LOOP
       If l_ship_to_org_id is not null and l_invoice_to_org_id is not null then
	 exit;
       End If;
      If l_ship_to_org_id is null and p_rul_tbl(i).code = 'STO' and p_rul_tbl(i).current_source = 'OKX_SHIPTO' then
	 l_ship_to_org_id := p_rul_tbl(i).source_value;
      END IF;
      If l_invoice_to_org_id is null and p_rul_tbl(i).code = 'BTO' and p_rul_tbl(i).current_source = 'OKX_BILLTO' then
	 l_invoice_to_org_id := p_rul_tbl(i).source_value;
      END IF;
	i:= p_rul_tbl.next(i);
     End loop;
     IF l_ship_to_org_id is not null THEN
	   x_site_use_info(1) := l_ship_to_org_id;
	   IF l_invoice_to_org_id is not null and l_ship_to_org_id <> l_invoice_to_org_id THEN
			    x_site_use_info(2) := l_invoice_to_org_id;
	   END IF;
     ELSE IF l_invoice_to_org_id is not null THEN
	         x_site_use_info(1) := l_invoice_to_org_id;
             END IF;
     END IF;
																		RETURN x_site_use_info;

END Get_Site_Use;


FUNCTION GET_INVOICE_TO_ORG_ID (p_rul_tbl IN GLOBAL_RPRLE_TBL_TYPE,p_rle_tbl IN GLOBAL_RPRLE_TBL_TYPE)
  RETURN NUMBER
IS

l_invoice_to_org_id number;
i    pls_integer :=0;
BEGIN
     i:=p_rul_tbl.first;
     While i is not null LOOP
      If  p_rul_tbl(i).code = 'BTO' and p_rul_tbl(i).current_source = 'OKX_CUSTACCT' then
	 l_invoice_to_org_id := p_rul_tbl(i).source_value;
         exit;
      END IF;
	i:= p_rul_tbl.next(i);
     End loop;
     IF l_invoice_to_org_id is null then
        i:=p_rle_tbl.first;
        While i is not null LOOP
           If  p_rle_tbl(i).code = 'BILL_TO' and p_rle_tbl(i).current_source = 'OKX_CUSTACCT' then
	      l_invoice_to_org_id := p_rle_tbl(i).source_value;
              exit;
           END IF;
	   i:= p_rle_tbl.next(i);
        End loop;
    END IF;

     return l_invoice_to_org_id;
END GET_INVOICE_TO_ORG_ID;

--???see if the vaue here can be cached in
FUNCTION GET_PARTY_ID (p_sold_to_org_id IN NUMBER) RETURN NUMBER IS

l_party_id NUMBER;

CURSOR get_party_id_cur(l_sold_to_org_id NUMBER) IS
 SELECT party_id
 FROM   okx_customer_accounts_v
 WHERE  id1 = l_sold_to_org_id;

BEGIN
  OPEN get_party_id_cur(p_sold_to_org_id);
  FETCH get_party_id_cur INTO l_party_id;
  CLOSE get_party_id_cur;
  RETURN l_party_id;


EXCEPTION
WHEN OTHERS THEN
  RETURN NULL;
END GET_PARTY_ID;

FUNCTION GET_SHIP_TO_PARTY_SITE_ID(p_rul_tbl IN GLOBAL_RPRLE_TBL_TYPE) RETURN NUMBER IS

l_ship_to_party_site_id NUMBER;
l_ship_id number;
i pls_integer :=0;
CURSOR get_ship_to_site_id_cur (l_ship_to_org_id NUMBER) IS
 SELECT a.party_site_id
 FROM   okx_cust_sites_v a,
        okx_cust_site_uses_v b
 WHERE  a.cust_acct_site_id = b.cust_acct_site_id
 AND    b.id1               = l_ship_to_org_id
 AND    b.site_use_code     = 'SHIP_TO';

BEGIN
   i:=p_rul_tbl.first;
   While i is not null LOOP
           If  p_rul_tbl(i).code = 'STO' and p_rul_tbl(i).current_source = 'OKX_SHIPTO' then
	      l_ship_id := p_rul_tbl(i).source_value;
              exit;
           END IF;
	   i:= p_rul_tbl.next(i);
  End loop;
  If l_ship_id is not null then
    OPEN get_ship_to_site_id_cur (l_ship_id);
    FETCH get_ship_to_site_id_cur INTO l_ship_to_party_site_id;
    CLOSE get_ship_to_site_id_cur;
  End If;
  RETURN l_ship_to_party_site_id;

EXCEPTION
WHEN OTHERS THEN
  RETURN NULL;
END GET_SHIP_TO_PARTY_SITE_ID;

FUNCTION GET_INVOICE_TO_PARTY_SITE_ID(p_rul_tbl IN GLOBAL_RPRLE_TBL_TYPE) RETURN NUMBER IS

l_bill_to_party_site_id NUMBER;
l_bill_id number;
i pls_integer :=0;
CURSOR get_bill_to_site_id_cur (l_bill_to_org_id NUMBER) IS
 SELECT a.party_site_id
 FROM   okx_cust_sites_v a,
        okx_cust_site_uses_v b
 WHERE  a.cust_acct_site_id = b.cust_acct_site_id
 AND    b.id1               = l_bill_to_org_id
 AND    b.site_use_code     = 'BILL_TO';

BEGIN
   i:=p_rul_tbl.first;
   While i is not null LOOP
           If  p_rul_tbl(i).code = 'BTO' and p_rul_tbl(i).current_source = 'OKX_BILLTO' then
	      l_bill_id := p_rul_tbl(i).source_value;
              exit;
           END IF;
	   i:= p_rul_tbl.next(i);
  End loop;
  If l_bill_id is not null then
    OPEN get_bill_to_site_id_cur (l_bill_id);
    FETCH get_bill_to_site_id_cur INTO l_bill_to_party_site_id;
    CLOSE get_bill_to_site_id_cur;
  End If;
  RETURN l_bill_to_party_site_id;

EXCEPTION
WHEN OTHERS THEN
  RETURN NULL;
END GET_INVOICE_TO_PARTY_SITE_ID;

---end added by smhanda----------------------------

END OKC_PRICE_PUB;

/
