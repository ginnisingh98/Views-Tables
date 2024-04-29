--------------------------------------------------------
--  DDL for Package Body BIC_CONSOLIDATE_CUST_DATA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIC_CONSOLIDATE_CUST_DATA_PKG" as
/* $Header: bicflatb.pls 115.10 2004/05/14 07:49:54 vsegu ship $ */

g_date     date ;
g_org_id   bic_dimv_operating_units.org_id % type;
g_party_id hz_parties.party_id % type;

procedure populate_party_data (p_start_date date,
				 p_end_date   date) is
  -- For a given date range, This cursor gets all parties,orgs and period,
  -- which have any data in bic_customer_summary_all
  cursor c_parties is
    select distinct customer_id, org_id, period_start_date
	 from bic_customer_summary_all
	where period_start_date between p_start_date and p_end_date;

  -- This cursor gets measure_code and its value for a party, org and period
  cursor c_measure_values is
    select measure_code, value
	 from bic_customer_summary_all
     where period_start_date = g_date
	  and customer_id       = g_party_id
	  and nvl(org_id,-99)   = nvl(g_org_id,-99);

  l_date          date;
  l_col_str varchar2(4000);
  l_val_str varchar2(4000);
  l_ins_str varchar2(4000);

  -- variables to hold value for each measure
  -- For each measure there is one variable.
   l_ACQUISITION                number;
   l_ACTIVATION                 number;
   l_RETENTION                  number;
   l_LIFE_CYCLE                 number;
   l_ASSOCIATION_YRS            number;
   l_AVG_CLOSED_SRS             number;
   l_AVG_COMPLAINTS             number;
   l_AVG_HOLD_TIME              number;
   l_AVG_INTERACTIONS           number;
   l_AVG_INTERACTIONS_PER_SR    number;
   l_AVG_LEN_OF_EMP             number;
   l_AVG_OUTSTANDING_SRS        number;
   l_AVG_PERIOD_FOR_ACTIVE_CONT number;
   l_AVG_SRS_LOGGED             number;
   l_AVG_SR_RESL_TIME           number;
   l_AVG_SR_RESPONSE_TIME       number;
   l_AVG_TALK_TIME              number;
   l_AVG_TRANSFERS_BEF_RESL     number;
   l_AVG_TRANSFERS_PER_SR       number;
   l_AVG_WORKLOAD               number;
   l_CALLS                      number;
   l_CALL_LENGTH                number;
   l_CALL_TYPE_INTERACTIONS     number;
   l_CLOSED_SRS                 number;
   l_COGS                       number;
   l_CONTRACTS_CUML             number;
   l_CONTRACT_AMT               number;
   l_CONTRACT_DURATION          number;
   l_ESC_SRS                    number;
   l_FIRST_CALL_CL_RATE         number;
   l_INACTIVE_CONTRACTS         number;
   l_INTERACTIONS               number;
   l_INTERAC_CUML               number;
   l_LOYALTY                    number;
   l_NEW_CONTRACTS              number;
   l_NO_OF_COMPLAINTS           number;
   l_NO_OF_INTERACTIONS         number;
   l_NO_OF_TRANSFERS            number;
   l_OL_DEL_VALUE               number;
   l_OL_ONTIME_VALUE            number;
   l_ONTIME_PAYMENTS            number;
   l_ONTIME_SHIP_PCT            number;
   l_ONTIME_VALUE_PCT           number;
   l_ON_TIME_PAYMENT_RATE       number;
   l_OPEN_CONTRACTS             number;
   l_OPEN_SRS                   number;
   l_ORDER_AMT                  number;
   l_ORDER_LINES_DELIVERED      number;
   l_ORDER_LINES_ONTIME         number;
   l_ORDER_NUM                  number;
   l_ORDER_QTY                  number;
   l_ORDER_QTY_CUML             number;
   l_ORDER_RECENCY              number;
   l_PAYMENTS                   number;
   l_PCT_ESC_SRS                number;
   l_PCT_REOPENED_SRS           number;
   l_PCT_RETURN_QTY             number;
   l_PERCT_CALL_REWORK          number;
   l_PRODUCTS                   number;
   l_PROFITABILITY              number;
   l_REFERALS                   number;
   l_RENEWED_CONTRACTS          number;
   l_REOPENED_SRS               number;
   l_RETURNS                    number;
   l_RETURN_BY_VALUE            number;
   l_RETURN_BY_VALUE_PCT        number;
   l_RETURN_QTY                 number;
   l_SALES                      number;
   l_SATISFACTION               number;
   l_SF_BILLING                 number;
   l_SF_CONTRACT                number;
   l_SF_QUALITY                 number;
   l_SF_SERVICE                 number;
   l_SF_SHIPMENT                number;
   l_SRS_LOGGED                 number;
   l_SR_CLOSED_INT              number;
   l_TOTAL_HOLD_TIME            number;
   l_TOTAL_LEN_OF_EMP           number;
   l_TOTAL_SR_RESL_TIME         number;
   l_TOTAL_SR_RESPONSE_TIME     number;


   l_measure_code   bic_measure_attribs.measure_code % type;
   l_measure_value  bic_customer_summary_all.value   % type;
begin
	g_date      := to_date('01-01-1999','dd-mm-yyyy') ;
  open c_parties;
  loop
    fetch c_parties into g_party_id, g_org_id, g_date;
    if c_parties % notfound then exit; end if;

    -- initialize values for measure_codes
    l_ACQUISITION                := null;
    l_ACTIVATION                 := null;
    l_RETENTION                  := null;
    l_LIFE_CYCLE                 := null;
    l_ASSOCIATION_YRS            := null;
    l_AVG_CLOSED_SRS             := null;
    l_AVG_COMPLAINTS             := null;
    l_AVG_HOLD_TIME              := null;
    l_AVG_INTERACTIONS           := null;
    l_AVG_INTERACTIONS_PER_SR    := null;
    l_AVG_LEN_OF_EMP             := null;
    l_AVG_OUTSTANDING_SRS        := null;
    l_AVG_PERIOD_FOR_ACTIVE_CONT := null;
    l_AVG_SRS_LOGGED             := null;
    l_AVG_SR_RESL_TIME           := null;
    l_AVG_SR_RESPONSE_TIME       := null;
    l_AVG_TALK_TIME              := null;
    l_AVG_TRANSFERS_BEF_RESL     := null;
    l_AVG_TRANSFERS_PER_SR       := null;
    l_AVG_WORKLOAD               := null;
    l_CALLS                      := null;
    l_CALL_LENGTH                := null;
    l_CALL_TYPE_INTERACTIONS     := null;
    l_CLOSED_SRS                 := null;
    l_COGS                       := null;
    l_CONTRACTS_CUML             := null;
    l_CONTRACT_AMT               := null;
    l_CONTRACT_DURATION          := null;
    l_ESC_SRS                    := null;
    l_FIRST_CALL_CL_RATE         := null;
    l_INACTIVE_CONTRACTS         := null;
    l_INTERACTIONS               := null;
    l_INTERAC_CUML               := null;
    l_LOYALTY                    := null;
    l_NEW_CONTRACTS              := null;
    l_NO_OF_COMPLAINTS           := null;
    l_NO_OF_INTERACTIONS         := null;
    l_NO_OF_TRANSFERS            := null;
    l_OL_DEL_VALUE               := null;
    l_OL_ONTIME_VALUE            := null;
    l_ONTIME_PAYMENTS            := null;
    l_ONTIME_SHIP_PCT            := null;
    l_ONTIME_VALUE_PCT           := null;
    l_ON_TIME_PAYMENT_RATE       := null;
    l_OPEN_CONTRACTS             := null;
    l_OPEN_SRS                   := null;
    l_ORDER_AMT                  := null;
    l_ORDER_LINES_DELIVERED      := null;
    l_ORDER_LINES_ONTIME         := null;
    l_ORDER_NUM                  := null;
    l_ORDER_QTY                  := null;
    l_ORDER_QTY_CUML             := null;
    l_ORDER_RECENCY              := null;
    l_PAYMENTS                   := null;
    l_PCT_ESC_SRS                := null;
    l_PCT_REOPENED_SRS           := null;
    l_PCT_RETURN_QTY             := null;
    l_PERCT_CALL_REWORK          := null;
    l_PRODUCTS                   := null;
    l_PROFITABILITY              := null;
    l_REFERALS                   := null;
    l_RENEWED_CONTRACTS          := null;
    l_REOPENED_SRS               := null;
    l_RETURNS                    := null;
    l_RETURN_BY_VALUE            := null;
    l_RETURN_BY_VALUE_PCT        := null;
    l_RETURN_QTY                 := null;
    l_SALES                      := null;
    l_SATISFACTION               := null;
    l_SF_BILLING                 := null;
    l_SF_CONTRACT                := null;
    l_SF_QUALITY                 := null;
    l_SF_SERVICE                 := null;
    l_SF_SHIPMENT                := null;
    l_SRS_LOGGED                 := null;
    l_SR_CLOSED_INT              := null;
    l_TOTAL_HOLD_TIME            := null;
    l_TOTAL_LEN_OF_EMP           := null;
    l_TOTAL_SR_RESL_TIME         := null;
    l_TOTAL_SR_RESPONSE_TIME     := null;

    -- This will get measures for a party, org and period and assign it to
    -- appropriate variable.
    open c_measure_values;
    loop
	  fetch c_measure_values into l_measure_code, l_measure_value;
	  if c_measure_values%notfound then exit; end if;
    if l_measure_code               = 'ACQUISITION' then
	 l_ACQUISITION                := l_measure_value;
    elsif l_measure_code            = 'ACTIVATION' then
	 l_ACTIVATION                 := l_measure_value;
    elsif l_measure_code            = 'ASSOCIATION_YRS' then
	 l_ASSOCIATION_YRS            := l_measure_value;
    elsif l_measure_code            = 'AVG_CLOSED_SRS' then
	 l_AVG_CLOSED_SRS             := l_measure_value;
    elsif l_measure_code            = 'AVG_COMPLAINTS' then
	 l_AVG_COMPLAINTS             := l_measure_value;
    elsif l_measure_code            = 'AVG_HOLD_TIME' then
	 l_AVG_HOLD_TIME              := l_measure_value;
    elsif l_measure_code            = 'AVG_INTERACTIONS' then
	 l_AVG_INTERACTIONS           := l_measure_value;
    elsif l_measure_code            = 'AVG_INTERACTIONS_PER_SR' then
	 l_AVG_INTERACTIONS_PER_SR    := l_measure_value;
    elsif l_measure_code            = 'AVG_LEN_OF_EMP' then
	 l_AVG_LEN_OF_EMP             := l_measure_value;
    elsif l_measure_code            = 'AVG_OUTSTANDING_SRS' then
	 l_AVG_OUTSTANDING_SRS        := l_measure_value;
    elsif l_measure_code            = 'AVG_PERIOD_FOR_ACTIVE_CONT' then
	 l_AVG_PERIOD_FOR_ACTIVE_CONT := l_measure_value;
    elsif l_measure_code            = 'AVG_SRS_LOGGED' then
	 l_AVG_SRS_LOGGED             := l_measure_value;
    elsif l_measure_code            = 'AVG_SR_RESL_TIME' then
	 l_AVG_SR_RESL_TIME           := l_measure_value;
    elsif l_measure_code            = 'AVG_SR_RESPONSE_TIME' then
	 l_AVG_SR_RESPONSE_TIME       := l_measure_value;
    elsif l_measure_code            = 'AVG_TALK_TIME' then
	 l_AVG_TALK_TIME              := l_measure_value;
    elsif l_measure_code            = 'AVG_TRANSFERS_BEF_RESL' then
	 l_AVG_TRANSFERS_BEF_RESL     := l_measure_value;
    elsif l_measure_code            = 'AVG_TRANSFERS_PER_SR' then
	 l_AVG_TRANSFERS_PER_SR       := l_measure_value;
    elsif l_measure_code            = 'AVG_WORKLOAD' then
	 l_AVG_WORKLOAD               := l_measure_value;
    elsif l_measure_code            = 'CALLS' then
	 l_CALLS                      := l_measure_value;
    elsif l_measure_code            = 'CALL_LENGTH' then
	 l_CALL_LENGTH                := l_measure_value;
    elsif l_measure_code            = 'CALL_TYPE_INTERACTIONS' then
	 l_CALL_TYPE_INTERACTIONS     := l_measure_value;
    elsif l_measure_code            = 'CLOSED_SRS' then
	 l_CLOSED_SRS                 := l_measure_value;
    elsif l_measure_code            = 'COGS' then
	 l_COGS                       := l_measure_value;
    elsif l_measure_code            = 'CONTRACTS_CUML' then
	 l_CONTRACTS_CUML             := l_measure_value;
    elsif l_measure_code            = 'CONTRACT_AMT' then
	 l_CONTRACT_AMT               := l_measure_value;
    elsif l_measure_code            = 'CONTRACT_DURATION' then
	 l_CONTRACT_DURATION          := l_measure_value;
    elsif l_measure_code            = 'ESC_SRS' then
	 l_ESC_SRS                    := l_measure_value;
    elsif l_measure_code            = 'FIRST_CALL_CL_RATE' then
	 l_FIRST_CALL_CL_RATE         := l_measure_value;
    elsif l_measure_code            = 'INACTIVE_CONTRACTS' then
	 l_INACTIVE_CONTRACTS         := l_measure_value;
    elsif l_measure_code            = 'INTERACTIONS' then
	 l_INTERACTIONS               := l_measure_value;
    elsif l_measure_code            = 'INTERAC_CUML' then
	 l_INTERAC_CUML               := l_measure_value;
    elsif l_measure_code            = 'LIFE_CYCLE' then
	 l_LIFE_CYCLE                 := l_measure_value;
    elsif l_measure_code            = 'LOYALTY' then
	 l_LOYALTY                    := l_measure_value;
    elsif l_measure_code            = 'NEW_CONTRACTS' then
	 l_NEW_CONTRACTS              := l_measure_value;
    elsif l_measure_code            = 'NO_OF_COMPLAINTS' then
	 l_NO_OF_COMPLAINTS           := l_measure_value;
    elsif l_measure_code            = 'NO_OF_INTERACTIONS' then
	 l_NO_OF_INTERACTIONS         := l_measure_value;
    elsif l_measure_code            = 'NO_OF_TRANSFERS' then
	 l_NO_OF_TRANSFERS            := l_measure_value;
    elsif l_measure_code            = 'OL_DEL_VALUE' then
	 l_OL_DEL_VALUE               := l_measure_value;
    elsif l_measure_code            = 'OL_ONTIME_VALUE' then
	 l_OL_ONTIME_VALUE            := l_measure_value;
    elsif l_measure_code            = 'ONTIME_PAYMENTS' then
	 l_ONTIME_PAYMENTS            := l_measure_value;
    elsif l_measure_code            = 'ONTIME_SHIP_PCT' then
	 l_ONTIME_SHIP_PCT            := l_measure_value;
    elsif l_measure_code            = 'ONTIME_VALUE_PCT' then
	 l_ONTIME_VALUE_PCT           := l_measure_value;
    elsif l_measure_code            = 'ON_TIME_PAYMENT_RATE' then
	 l_ON_TIME_PAYMENT_RATE       := l_measure_value;
    elsif l_measure_code            = 'OPEN_CONTRACTS' then
	 l_OPEN_CONTRACTS             := l_measure_value;
    elsif l_measure_code            = 'OPEN_SRS' then
	 l_OPEN_SRS                   := l_measure_value;
    elsif l_measure_code            = 'ORDER_AMT' then
	 l_ORDER_AMT                  := l_measure_value;
    elsif l_measure_code            = 'ORDER_LINES_DELIVERED' then
	 l_ORDER_LINES_DELIVERED      := l_measure_value;
    elsif l_measure_code            = 'ORDER_LINES_ONTIME' then
	 l_ORDER_LINES_ONTIME         := l_measure_value;
    elsif l_measure_code            = 'ORDER_NUM' then
	 l_ORDER_NUM                  := l_measure_value;
    elsif l_measure_code            = 'ORDER_QTY' then
	 l_ORDER_QTY                  := l_measure_value;
    elsif l_measure_code            = 'ORDER_QTY_CUML' then
	 l_ORDER_QTY_CUML             := l_measure_value;
    elsif l_measure_code            = 'ORDER_RECENCY' then
	 l_ORDER_RECENCY              := l_measure_value;
    elsif l_measure_code            = 'PAYMENTS' then
	 l_PAYMENTS                   := l_measure_value;
    elsif l_measure_code            = 'PCT_ESC_SRS'              then
	 l_PCT_ESC_SRS                := l_measure_value;
    elsif l_measure_code            = 'PCT_REOPENED_SRS'         then
	 l_PCT_REOPENED_SRS           := l_measure_value;
    elsif l_measure_code            = 'PCT_RETURN_QTY'           then
	 l_PCT_RETURN_QTY             := l_measure_value;
    elsif l_measure_code            = 'PERCT_CALL_REWORK'        then
	 l_PERCT_CALL_REWORK          := l_measure_value;
    elsif l_measure_code            = 'PRODUCTS'                 then
	 l_PRODUCTS                   := l_measure_value;
    elsif l_measure_code            = 'PROFITABILITY'            then
	 l_PROFITABILITY              := l_measure_value;
    elsif l_measure_code            = 'REFERALS'                 then
	 l_REFERALS                   := l_measure_value;
    elsif l_measure_code            = 'RENEWED_CONTRACTS'        then
	 l_RENEWED_CONTRACTS          := l_measure_value;
    elsif l_measure_code            = 'REOPENED_SRS'             then
	 l_REOPENED_SRS               := l_measure_value;
    elsif l_measure_code            = 'RETENTION'                then
	 l_RETENTION                  := l_measure_value;
    elsif l_measure_code            = 'RETURNS'                  then
	 l_RETURNS                    := l_measure_value;
    elsif l_measure_code            = 'RETURN_BY_VALUE'          then
	 l_RETURN_BY_VALUE            := l_measure_value;
    elsif l_measure_code            = 'RETURN_BY_VALUE_PCT'      then
	 l_RETURN_BY_VALUE_PCT        := l_measure_value;
    elsif l_measure_code            = 'RETURN_QTY'               then
	 l_RETURN_QTY                 := l_measure_value;
    elsif l_measure_code            = 'SALES'                    then
	 l_SALES                      := l_measure_value;
    elsif l_measure_code            = 'SATISFACTION'             then
	 l_SATISFACTION               := l_measure_value;
    elsif l_measure_code            = 'SF_BILLING'               then
	 l_SF_BILLING                 := l_measure_value;
    elsif l_measure_code            = 'SF_CONTRACT'              then
	 l_SF_CONTRACT                := l_measure_value;
    elsif l_measure_code            = 'SF_QUALITY'               then
	 l_SF_QUALITY                 := l_measure_value;
    elsif l_measure_code            = 'SF_SERVICE'               then
	 l_SF_SERVICE                 := l_measure_value;
    elsif l_measure_code            = 'SF_SHIPMENT'              then
	 l_SF_SHIPMENT                := l_measure_value;
    elsif l_measure_code            = 'SRS_LOGGED'               then
	 l_SRS_LOGGED                 := l_measure_value;
    elsif l_measure_code            = 'SR_CLOSED_INT'            then
	 l_SR_CLOSED_INT              := l_measure_value;
    elsif l_measure_code            = 'TOTAL_HOLD_TIME'          then
	 l_TOTAL_HOLD_TIME            := l_measure_value;
    elsif l_measure_code            = 'TOTAL_LEN_OF_EMP'         then
	 l_TOTAL_LEN_OF_EMP           := l_measure_value;
    elsif l_measure_code            = 'TOTAL_SR_RESL_TIME'       then
	 l_TOTAL_SR_RESL_TIME         := l_measure_value;
    elsif l_measure_code            = 'TOTAL_SR_RESPONSE_TIME'   then
	 l_TOTAL_SR_RESPONSE_TIME     := l_measure_value;
    end if;
    /***********************
    select ' elsif l_measure_code = ''' || measure_code || ''' then
   	   l_' || measure_code || ' = l_measure_value'
    from bic_measure_attribs
    *****************************/
    end loop;
    close c_measure_values;

    -- Begin statement is used for exception handling.
    begin
      update bic_party_summ set
         ASSOCIATION_YRS            = nvl(l_ASSOCIATION_YRS           , ASSOCIATION_YRS                ),
         AVG_CLOSED_SRS             = nvl(l_AVG_CLOSED_SRS            , AVG_CLOSED_SRS                 ),
         AVG_COMPLAINTS             = nvl(l_AVG_COMPLAINTS            , AVG_COMPLAINTS                 ),
         AVG_HOLD_TIME              = nvl(l_AVG_HOLD_TIME             , AVG_HOLD_TIME                  ),
         AVG_INTERACTIONS           = nvl(l_AVG_INTERACTIONS          , AVG_INTERACTIONS               ),
         AVG_INTERACTIONS_PER_SR    = nvl(l_AVG_INTERACTIONS_PER_SR   , AVG_INTERACTIONS_PER_SR        ),
         AVG_LEN_OF_EMP             = nvl(l_AVG_LEN_OF_EMP            , AVG_LEN_OF_EMP                 ),
         AVG_OUTSTANDING_SRS        = nvl(l_AVG_OUTSTANDING_SRS       , AVG_OUTSTANDING_SRS            ),
         AVG_PERIOD_FOR_ACTIVE_CONT = nvl(l_AVG_PERIOD_FOR_ACTIVE_CONT, AVG_PERIOD_FOR_ACTIVE_CONT     ),
         AVG_SRS_LOGGED             = nvl(l_AVG_SRS_LOGGED            , AVG_SRS_LOGGED                 ),
         AVG_SR_RESL_TIME           = nvl(l_AVG_SR_RESL_TIME          , AVG_SR_RESL_TIME               ),
         AVG_SR_RESPONSE_TIME       = nvl(l_AVG_SR_RESPONSE_TIME      , AVG_SR_RESPONSE_TIME           ),
         AVG_TALK_TIME              = nvl(l_AVG_TALK_TIME             , AVG_TALK_TIME                  ),
         AVG_TRANSFERS_BEF_RESL     = nvl(l_AVG_TRANSFERS_BEF_RESL    , AVG_TRANSFERS_BEF_RESL         ),
         AVG_TRANSFERS_PER_SR       = nvl(l_AVG_TRANSFERS_PER_SR      , AVG_TRANSFERS_PER_SR           ),
         AVG_WORKLOAD               = nvl(l_AVG_WORKLOAD              , AVG_WORKLOAD                   ),
         CALLS                      = nvl(l_CALLS                     , CALLS                          ),
         CALL_LENGTH                = nvl(l_CALL_LENGTH               , CALL_LENGTH                    ),
         CALL_TYPE_INTERACTIONS     = nvl(l_CALL_TYPE_INTERACTIONS    , CALL_TYPE_INTERACTIONS         ),
         CLOSED_SRS                 = nvl(l_CLOSED_SRS                , CLOSED_SRS                     ),
         COGS                       = nvl(l_COGS                      , COGS                           ),
         CONTRACTS_CUML             = nvl(l_CONTRACTS_CUML            , CONTRACTS_CUML                 ),
         CONTRACT_AMT               = nvl(l_CONTRACT_AMT              , CONTRACT_AMT                   ),
         CONTRACT_DURATION          = nvl(l_CONTRACT_DURATION         , CONTRACT_DURATION              ),
         ESC_SRS                    = nvl(l_ESC_SRS                   , ESC_SRS                        ),
         FIRST_CALL_CL_RATE         = nvl(l_FIRST_CALL_CL_RATE        , FIRST_CALL_CL_RATE             ),
         INACTIVE_CONTRACTS         = nvl(l_INACTIVE_CONTRACTS        , INACTIVE_CONTRACTS             ),
         INTERACTIONS               = nvl(l_INTERACTIONS              , INTERACTIONS                   ),
         INTERAC_CUML               = nvl(l_INTERAC_CUML              , INTERAC_CUML                   ),
         LOYALTY                    = nvl(l_LOYALTY                   , LOYALTY                        ),
         NEW_CONTRACTS              = nvl(l_NEW_CONTRACTS             , NEW_CONTRACTS                  ),
         NO_OF_COMPLAINTS           = nvl(l_NO_OF_COMPLAINTS          , NO_OF_COMPLAINTS               ),
         NO_OF_INTERACTIONS         = nvl(l_NO_OF_INTERACTIONS        , NO_OF_INTERACTIONS             ),
         NO_OF_TRANSFERS            = nvl(l_NO_OF_TRANSFERS           , NO_OF_TRANSFERS                ),
         OL_DEL_VALUE               = nvl(l_OL_DEL_VALUE              , OL_DEL_VALUE                   ),
         OL_ONTIME_VALUE            = nvl(l_OL_ONTIME_VALUE           , OL_ONTIME_VALUE                ),
         ONTIME_PAYMENTS            = nvl(l_ONTIME_PAYMENTS           , ONTIME_PAYMENTS                ),
         ONTIME_SHIP_PCT            = nvl(l_ONTIME_SHIP_PCT           , ONTIME_SHIP_PCT                ),
         ONTIME_VALUE_PCT           = nvl(l_ONTIME_VALUE_PCT          , ONTIME_VALUE_PCT               ),
         ON_TIME_PAYMENT_RATE       = nvl(l_ON_TIME_PAYMENT_RATE      , ON_TIME_PAYMENT_RATE           ),
         OPEN_CONTRACTS             = nvl(l_OPEN_CONTRACTS            , OPEN_CONTRACTS                 ),
         OPEN_SRS                   = nvl(l_OPEN_SRS                  , OPEN_SRS                       ),
         ORDER_AMT                  = nvl(l_ORDER_AMT                 , ORDER_AMT                      ),
         ORDER_LINES_DELIVERED      = nvl(l_ORDER_LINES_DELIVERED     , ORDER_LINES_DELIVERED          ),
         ORDER_LINES_ONTIME         = nvl(l_ORDER_LINES_ONTIME        , ORDER_LINES_ONTIME             ),
         ORDER_NUM                  = nvl(l_ORDER_NUM                 , ORDER_NUM                      ),
         ORDER_QTY                  = nvl(l_ORDER_QTY                 , ORDER_QTY                      ),
         ORDER_QTY_CUML             = nvl(l_ORDER_QTY_CUML            , ORDER_QTY_CUML                 ),
         ORDER_RECENCY              = nvl(l_ORDER_RECENCY             , ORDER_RECENCY                  ),
         PAYMENTS                   = nvl(l_PAYMENTS                  , PAYMENTS                       ),
         PCT_ESC_SRS                = nvl(l_PCT_ESC_SRS               , PCT_ESC_SRS                    ),
         PCT_REOPENED_SRS           = nvl(l_PCT_REOPENED_SRS          , PCT_REOPENED_SRS               ),
         PCT_RETURN_QTY             = nvl(l_PCT_RETURN_QTY            , PCT_RETURN_QTY                 ),
         PERCT_CALL_REWORK          = nvl(l_PERCT_CALL_REWORK         , PERCT_CALL_REWORK              ),
         PRODUCTS                   = nvl(l_PRODUCTS                  , PRODUCTS                       ),
         PROFITABILITY              = nvl(l_PROFITABILITY             , PROFITABILITY                  ),
         REFERALS                   = nvl(l_REFERALS                  , REFERALS                       ),
         RENEWED_CONTRACTS          = nvl(l_RENEWED_CONTRACTS         , RENEWED_CONTRACTS              ),
         REOPENED_SRS               = nvl(l_REOPENED_SRS              , REOPENED_SRS                   ),
         RETURNS                    = nvl(l_RETURNS                   , RETURNS                        ),
         RETURN_BY_VALUE            = nvl(l_RETURN_BY_VALUE           , RETURN_BY_VALUE                ),
         RETURN_BY_VALUE_PCT        = nvl(l_RETURN_BY_VALUE_PCT       , RETURN_BY_VALUE_PCT            ),
         RETURN_QTY                 = nvl(l_RETURN_QTY                , RETURN_QTY                     ),
         SALES                      = nvl(l_SALES                     , SALES                          ),
         SATISFACTION               = nvl(l_SATISFACTION              , SATISFACTION                   ),
         SF_BILLING                 = nvl(l_SF_BILLING                , SF_BILLING                     ),
         SF_CONTRACT                = nvl(l_SF_CONTRACT               , SF_CONTRACT                    ),
         SF_QUALITY                 = nvl(l_SF_QUALITY                , SF_QUALITY                     ),
         SF_SERVICE                 = nvl(l_SF_SERVICE                , SF_SERVICE                     ),
         SF_SHIPMENT                = nvl(l_SF_SHIPMENT               , SF_SHIPMENT                    ),
         SRS_LOGGED                 = nvl(l_SRS_LOGGED                , SRS_LOGGED                     ),
         SR_CLOSED_INT              = nvl(l_SR_CLOSED_INT             , SR_CLOSED_INT                  ),
         TOTAL_HOLD_TIME            = nvl(l_TOTAL_HOLD_TIME           , TOTAL_HOLD_TIME                ),
         TOTAL_LEN_OF_EMP           = nvl(l_TOTAL_LEN_OF_EMP          , TOTAL_LEN_OF_EMP               ),
         TOTAL_SR_RESL_TIME         = nvl(l_TOTAL_SR_RESL_TIME        , TOTAL_SR_RESL_TIME             ),
         TOTAL_SR_RESPONSE_TIME     = nvl(l_TOTAL_SR_RESPONSE_TIME    , TOTAL_SR_RESPONSE_TIME         )
      where period_start_date = g_date
        and party_id          = g_party_id
        and nvl(org_id,-99)   = nvl(g_org_id,-99);

     if sql%notfound then
        insert into bic_party_summ (
                 party_id   ,
			  org_id,
			  period_start_date,
                 ASSOCIATION_YRS           ,
                 AVG_CLOSED_SRS            ,
                 AVG_COMPLAINTS            ,
                 AVG_HOLD_TIME             ,
                 AVG_INTERACTIONS          ,
                 AVG_INTERACTIONS_PER_SR   ,
                 AVG_LEN_OF_EMP            ,
                 AVG_OUTSTANDING_SRS       ,
                 AVG_PERIOD_FOR_ACTIVE_CONT,
                 AVG_SRS_LOGGED            ,
                 AVG_SR_RESL_TIME          ,
                 AVG_SR_RESPONSE_TIME      ,
                 AVG_TALK_TIME             ,
                 AVG_TRANSFERS_BEF_RESL    ,
                 AVG_TRANSFERS_PER_SR      ,
                 AVG_WORKLOAD              ,
                 CALLS                     ,
                 CALL_LENGTH               ,
                 CALL_TYPE_INTERACTIONS    ,
                 CLOSED_SRS                ,
                 COGS                      ,
                 CONTRACTS_CUML            ,
                 CONTRACT_AMT              ,
                 CONTRACT_DURATION         ,
                 ESC_SRS                   ,
                 FIRST_CALL_CL_RATE        ,
                 INACTIVE_CONTRACTS        ,
                 INTERACTIONS              ,
                 INTERAC_CUML              ,
                 LOYALTY                   ,
                 NEW_CONTRACTS             ,
                 NO_OF_COMPLAINTS          ,
                 NO_OF_INTERACTIONS        ,
                 NO_OF_TRANSFERS           ,
                 OL_DEL_VALUE              ,
                 OL_ONTIME_VALUE           ,
                 ONTIME_PAYMENTS           ,
                 ONTIME_SHIP_PCT           ,
                 ONTIME_VALUE_PCT          ,
                 ON_TIME_PAYMENT_RATE      ,
                 OPEN_CONTRACTS            ,
                 OPEN_SRS                  ,
                 ORDER_AMT                 ,
                 ORDER_LINES_DELIVERED     ,
                 ORDER_LINES_ONTIME        ,
                 ORDER_NUM                 ,
                 ORDER_QTY                 ,
                 ORDER_QTY_CUML            ,
                 ORDER_RECENCY             ,
                 PAYMENTS                  ,
                 PCT_ESC_SRS               ,
                 PCT_REOPENED_SRS          ,
                 PCT_RETURN_QTY            ,
                 PERCT_CALL_REWORK         ,
                 PRODUCTS                  ,
                 PROFITABILITY             ,
                 REFERALS                  ,
                 RENEWED_CONTRACTS         ,
                 REOPENED_SRS              ,
                 RETURNS                   ,
                 RETURN_BY_VALUE           ,
                 RETURN_BY_VALUE_PCT       ,
                 RETURN_QTY                ,
                 SALES                     ,
                 SATISFACTION              ,
                 SF_BILLING                ,
                 SF_CONTRACT               ,
                 SF_QUALITY                ,
                 SF_SERVICE                ,
                 SF_SHIPMENT               ,
                 SRS_LOGGED                ,
                 SR_CLOSED_INT             ,
                 TOTAL_HOLD_TIME           ,
                 TOTAL_LEN_OF_EMP          ,
                 TOTAL_SR_RESL_TIME        ,
                 TOTAL_SR_RESPONSE_TIME    ,
                 last_updated_by           ,
                 created_by                ,
                 last_update_date          ,
                 creation_date             )
        values ( g_party_id,
			  g_org_id,
			  g_date,
			  --l_ACQUISITION               ,
                 --l_ACTIVATION                ,
                 l_ASSOCIATION_YRS           ,
                 l_AVG_CLOSED_SRS            ,
                 l_AVG_COMPLAINTS            ,
                 l_AVG_HOLD_TIME             ,
                 l_AVG_INTERACTIONS          ,
                 l_AVG_INTERACTIONS_PER_SR   ,
                 l_AVG_LEN_OF_EMP            ,
                 l_AVG_OUTSTANDING_SRS       ,
                 l_AVG_PERIOD_FOR_ACTIVE_CONT,
                 l_AVG_SRS_LOGGED            ,
                 l_AVG_SR_RESL_TIME          ,
                 l_AVG_SR_RESPONSE_TIME      ,
                 l_AVG_TALK_TIME             ,
                 l_AVG_TRANSFERS_BEF_RESL    ,
                 l_AVG_TRANSFERS_PER_SR      ,
                 l_AVG_WORKLOAD              ,
                 l_CALLS                     ,
                 l_CALL_LENGTH               ,
                 l_CALL_TYPE_INTERACTIONS    ,
                 l_CLOSED_SRS                ,
                 l_COGS                      ,
                 l_CONTRACTS_CUML            ,
                 l_CONTRACT_AMT              ,
                 l_CONTRACT_DURATION         ,
                 l_ESC_SRS                   ,
                 l_FIRST_CALL_CL_RATE        ,
                 l_INACTIVE_CONTRACTS        ,
                 l_INTERACTIONS              ,
                 l_INTERAC_CUML              ,
                 --l_LIFE_CYCLE                ,
                 l_LOYALTY                   ,
                 l_NEW_CONTRACTS             ,
                 l_NO_OF_COMPLAINTS          ,
                 l_NO_OF_INTERACTIONS        ,
                 l_NO_OF_TRANSFERS           ,
                 l_OL_DEL_VALUE              ,
                 l_OL_ONTIME_VALUE           ,
                 l_ONTIME_PAYMENTS           ,
                 l_ONTIME_SHIP_PCT           ,
                 l_ONTIME_VALUE_PCT          ,
                 l_ON_TIME_PAYMENT_RATE      ,
                 l_OPEN_CONTRACTS            ,
                 l_OPEN_SRS                  ,
                 l_ORDER_AMT                 ,
                 l_ORDER_LINES_DELIVERED     ,
                 l_ORDER_LINES_ONTIME        ,
                 l_ORDER_NUM                 ,
                 l_ORDER_QTY                 ,
                 l_ORDER_QTY_CUML            ,
                 l_ORDER_RECENCY             ,
                 l_PAYMENTS                  ,
                 l_PCT_ESC_SRS               ,
                 l_PCT_REOPENED_SRS          ,
                 l_PCT_RETURN_QTY            ,
                 l_PERCT_CALL_REWORK         ,
                 l_PRODUCTS                  ,
                 l_PROFITABILITY             ,
                 l_REFERALS                  ,
                 l_RENEWED_CONTRACTS         ,
                 l_REOPENED_SRS              ,
                 --l_RETENTION                 ,
                 l_RETURNS                   ,
                 l_RETURN_BY_VALUE           ,
                 l_RETURN_BY_VALUE_PCT       ,
                 l_RETURN_QTY                ,
                 l_SALES                     ,
                 l_SATISFACTION              ,
                 l_SF_BILLING                ,
                 l_SF_CONTRACT               ,
                 l_SF_QUALITY                ,
                 l_SF_SERVICE                ,
                 l_SF_SHIPMENT               ,
                 l_SRS_LOGGED                ,
                 l_SR_CLOSED_INT             ,
                 l_TOTAL_HOLD_TIME           ,
                 l_TOTAL_LEN_OF_EMP          ,
                 l_TOTAL_SR_RESL_TIME        ,
		 l_TOTAL_SR_RESPONSE_TIME    ,
                 0,0,sysdate,sysdate);
	  end if;
    exception
	 when others then
	      fnd_file.put_line(fnd_file.log,
		    'Error for party id:' || to_char(g_party_id) ||
		    ' Org Id:' || to_char(g_org_id) ||
		    ' date:' || to_char(g_date,'dd-mon-yyyy') || '-'||
		    substr(sqlerrm,1,200));
		  /*
            x_err := sqlerrm;
            insert into bic_debug (report_id, message)
	         values ( 'SKM','Party_id:' || to_char(g_party_id) ||
                          x_err
                        );
      	  commit;
		  *******************************/
  end; -- of block for inserting record into bic_party_summ table.

  end loop;
  close c_parties;
end populate_party_data;
----
----
procedure populate_status_data (p_start_date date,
	                 		  p_end_date   date,  p_measure_code varchar2) is
  -- For a given date range, This cursor gets all parties and period,
  -- which have any data in bic_customer_summary_all
  cursor c_parties is
    select distinct party_id, period_start_date
	 from bic_party_summary
	where period_start_date between p_start_date and p_end_date;

  -- This cursor gets measure_code and its value for a party and period
  cursor c_measure_values is
    select measure_code, value
	 from bic_party_summary
     where period_start_date = g_date
	  and party_id          = g_party_id;

  l_date          date;
  l_col_str varchar2(4000);
  l_val_str varchar2(4000);
  l_ins_str varchar2(4000);

  -- variables to hold value for each measure
  -- For each measure there is one variable.
   l_ACQUISITION                number;
   l_ACTIVATION                 number;
   l_RETENTION                  number;
   l_LIFE_CYCLE                 number;

   l_measure_code   bic_measure_attribs.measure_code % type;
   l_measure_value  bic_customer_summary_all.value   % type;
   x_err varchar2(2000);
begin
	g_date      := to_date('01-01-1999','dd-mm-yyyy') ;
  open c_parties;
  loop
    fetch c_parties into g_party_id,  g_date;
    if c_parties % notfound then exit; end if;

    -- initialize values for measure_codes
    l_ACQUISITION                := null;
    l_ACTIVATION                 := null;
    l_RETENTION                  := null;
    -- l_LIFE_CYCLE                 := null ; changed by kalyan April 19

    IF rtrim(ltrim(p_measure_code)) = 'LIFE_CYCLE' THEN
    l_LIFE_CYCLE                 := 6 ;
    ELSE
    l_LIFE_CYCLE                 := null;
    END IF;

    -- This will get measures for a party, org and period and assign it to
    -- appropriate variable.
    open c_measure_values;
    loop
	  fetch c_measure_values into l_measure_code, l_measure_value;
	  if c_measure_values%notfound then exit; end if;
       if l_measure_code               = 'ACQUISITION' then
	    l_ACQUISITION                := l_measure_value;
       elsif l_measure_code            = 'ACTIVATION' then
	    l_ACTIVATION                 := l_measure_value;
       elsif l_measure_code            = 'LIFE_CYCLE' then
	    l_LIFE_CYCLE                 := l_measure_value;
       elsif l_measure_code            = 'RETENTION'                then
	    l_RETENTION                  := l_measure_value;
       end if;

    end loop;
    close c_measure_values;

    -- Begin statement is used for exception handling.
    begin
    update bic_party_status_summ
	  set acquisition = nvl(l_acquisition, acquisition),
		 activation  = nvl(l_activation , activation ),
		 retention   = nvl(l_retention  , retention  ),
		 life_cycle  = nvl(l_life_cycle , life_cycle )
     where period_start_date = g_date
	  and party_id          = g_party_id;

    if sql%notfound then
       insert into bic_party_status_summ (
                 party_id         ,
			  period_start_date,
			  ACQUISITION      ,
                 ACTIVATION       ,
                 RETENTION        ,
                 LIFE_CYCLE       ,
                 last_updated_by,
                 created_by,
                 last_update_date,
                 creation_date)
        values ( g_party_id       ,
			  g_date           ,
			  l_ACQUISITION    ,
                 l_ACTIVATION     ,
                 l_RETENTION      ,
                 l_LIFE_CYCLE       ,
                 0,0,sysdate,sysdate );
    end if;
	  exception
	    when others then
	      fnd_file.put_line(fnd_file.log,
		    'Error n bic_party_status_summ for party id:' ||
									  to_char(g_party_id) ||
		    ' date:' || to_char(g_date,'dd-mon-yyyy') || '-'||
		    substr(sqlerrm,1,200));
		 /*******
            x_err := sqlerrm;
            insert into bic_debug (report_id, message)
	         values ( 'SKM','Party_id:' || to_char(g_party_id) ||
                          x_err
                        );
            commit;
		  ******************/
  end; -- of block for inserting record into bic_party_summ table.

  end loop;
  close c_parties;
end populate_status_data;
----
----
-- This procedure updates market segment for each party in bic_party_summ
-- and bic_party_status_summ tables.
procedure update_market_segment is
begin
  update bic_party_summ summ
    set market_segment_id = (select market_segment_id
						 from ams_party_market_segments mseg
                              where market_segment_flag = 'Y'
						  and mseg.party_id = summ.party_id
						  and rownum = 1);
  update bic_party_status_summ summ
    set market_segment_id = (select market_segment_id
						 from ams_party_market_segments mseg
                              where market_segment_flag = 'Y'
						  and mseg.party_id = summ.party_id
						  and rownum = 1);
                commit;
   exception when others then
                rollback;
end update_market_segment;
----
procedure main_proc(p_start_date date,
      			p_end_date   date) is
begin
  --populate_status_data(p_start_date, p_end_date);
  --populate_party_data (p_start_date, p_end_date);
  update_market_segment;
end main_proc;
procedure purge_summary_data (p_start_date date,
				          p_end_date   date) is
begin
  -- delete records from bic_customer_summary_all
  delete from bic_customer_summary_all
   where period_start_date between p_start_date and p_end_date;
  commit;

  -- delete records from bic_party_summary
  delete from bic_party_summary
   where period_start_date between p_start_date and p_end_date;
  commit;
end purge_summary_data;

procedure purge_party_summary_data is
begin

  -- delete records from bic_party_summary
  delete
  from 	bic_party_summary;
  -- commit;
end purge_party_summary_data;

procedure purge_customer_summary_data is
begin

  -- delete records from bic_customer_summary_all
  delete
  from	bic_customer_summary_all;
  -- commit;

end purge_customer_summary_data;
-- End of packqage body
end bic_consolidate_cust_data_pkg ;

/
