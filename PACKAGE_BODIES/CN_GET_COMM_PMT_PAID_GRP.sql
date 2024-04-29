--------------------------------------------------------
--  DDL for Package Body CN_GET_COMM_PMT_PAID_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_GET_COMM_PMT_PAID_GRP" AS
-- $Header: cnggcppb.pls 120.0 2005/08/08 00:14:23 appldev noship $
      g_api_version           CONSTANT NUMBER := 1.0;
      g_pkg_name              CONSTANT VARCHAR2(30) := 'CN_GET_COMM_PMT_PAID_GRP';
      g_credit_type_id        CONSTANT NUMBER := -1000;

PROCEDURE get_from_currency
(
    p_org_id cn_salesreps.org_id%TYPE,
    x_from_currency OUT NOCOPY gl_sets_of_books.currency_code%TYPE
)
IS
    CURSOR get_source_currency_code(p_org_id cn_salesreps.org_id%TYPE)
    IS
    SELECT gsob.currency_code from_currency
    FROM cn_repositories_all repo,
        gl_sets_of_books gsob
    WHERE repo.org_id = p_org_id
    AND repo.application_id = 283
    AND repo.set_of_books_id = gsob.set_of_books_id;
BEGIN
    FOR i IN get_source_currency_code(p_org_id)
    LOOP
        x_from_currency := i.from_currency;
    END LOOP;
END get_from_currency;

PROCEDURE get_conversion_rate
(
    p_from_currency gl_sets_of_books.currency_code%TYPE,
    p_to_currency gl_sets_of_books.currency_code%TYPE,
    p_conversion_date DATE,
    p_conversion_type gl_daily_conversion_types.conversion_type%TYPE,
    x_rate OUT NOCOPY NUMBER
)
IS
    l_numerator NUMBER;
    l_denominator NUMBER;
    l_rate NUMBER;
BEGIN
    gl_currency_api.get_closest_triangulation_rate (
        x_from_currency => p_from_currency,
        x_to_currency => p_to_currency,
        x_conversion_date => p_conversion_date,
        x_conversion_type => p_conversion_type,
        x_max_roll_days => 0,
        x_denominator => l_denominator,
        x_numerator => l_numerator,
        x_rate => l_rate);

    x_rate := l_rate;
EXCEPTION
    WHEN OTHERS
    THEN
        x_rate := NULL;
END get_conversion_rate;

PROCEDURE get_prorated_days
(
    p_start_date DATE,
    p_end_date DATE,
    x_prorated_days OUT NOCOPY NUMBER
)
IS
    CURSOR get_prorated_days(p_start_date DATE, p_end_date DATE)
    IS
    SELECT (p_end_date - p_start_date + 1) prorated_days
    FROM dual;
BEGIN
    FOR i IN get_prorated_days(p_start_date, p_end_date)
    LOOP
        x_prorated_days := i.prorated_days;
    END LOOP;
END get_prorated_days;

PROCEDURE debug_msg(msg IN VARCHAR2) IS
BEGIN
    --dbms_output.put_line(msg);
    NULL;
END;

-- ===========================================================================
--   Procedure   : get_comm_and_paid_pmt.
--   Description : This public procedure is used to get the commission earned and payment
--                  paid amount from OIC.
--   The following is added for compensation earned as p_proration_flag
--                  is for compensation earned.
--   For example, p_start_date  :   15-Jan-04
--                p_end_date    :   15-Feb-04
--                i)In Jan, comp is $1000 and in Feb, comp is $2000.
--                If the p_proration_flag  : FND_API.G_TRUE ('T')
--      Then we need to sum up all amount for the Jan and Feb and then prorate for
--      15-Jan-04 to 15-Feb-04 to (1000+2000)* (17+15)/(31+15)and return new date ranges as:
--                  x_new_start_date    : 01-Jan-04
--                  x_new_end_date      : 28-Feb-04
--                ii)If the p_proration_flag  : FND_API.G_FALSE ('F')
--      Then we need to sum up all amount for the Jan and Feb (1000+ 2000) and return new date ranges as:
--                  x_new_start_date    : 01-Jan-04
--                  x_new_end_date      : 28-Feb-04
-- Both x_new_start_date and x_new_end_date will not be NULL if they are the same across the orgs.
-- Both x_new_start_date and x_new_end_date will be NULL if they are different across the orgs.
-- ===========================================================================
PROCEDURE get_comm_and_paid_pmt
(
    p_api_version IN NUMBER,
    p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
    p_person_id IN NUMBER,
    p_start_date IN DATE,
    p_end_date IN DATE,
    p_target_currency_code IN VARCHAR2,
    p_proration_flag IN VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2,
    x_comp_earned OUT NOCOPY NUMBER,
    x_comp_paid OUT NOCOPY NUMBER,
    x_new_start_date OUT NOCOPY Date,
    x_new_end_date OUT NOCOPY Date
)
IS
    CURSOR get_org_and_srp_id(p_person_id jtf_rs_salesreps.person_id%TYPE)
    IS
    SELECT rs.org_id, rs.salesrep_id, hou.name operating_unit
    FROM jtf_rs_salesreps rs, jtf_rs_resource_extns rre,
    hr_operating_units hou
    WHERE rre.source_id = p_person_id
    AND rre.resource_id = rs.resource_id
    AND rre.category = 'EMPLOYEE'
    AND rs.org_id = hou.organization_id;

    CURSOR get_period_ids(p_start_date cn_period_statuses_all.start_date%TYPE,
                        p_end_date cn_period_statuses_all.end_date%TYPE,
                        p_org_id cn_period_statuses_all.org_id%TYPE)
    IS
    SELECT min(period_id) start_period_id, max(period_id) end_period_id,
           min(start_date) new_start_date, max(end_date) new_end_date,
           (max(end_date) - min(start_date) + 1) total_days
    FROM cn_period_statuses_all
    WHERE start_date <= p_end_date
    AND p_start_date <= end_date
    AND org_id = p_org_id
    ORDER BY period_id;

    CURSOR get_comm_and_pmt(p_salesrep_id jtf_rs_salesreps.salesrep_id%TYPE,
                          p_start_period_id cn_period_statuses_all.period_id%TYPE,
                          p_end_period_id cn_period_statuses_all.period_id%TYPE,
                          p_org_id cn_srp_periods_all.org_id%TYPE)
    IS
    SELECT NVL(SUM(NVL(balance2_dtd,0)),0) commission,
           NVL(SUM(NVL(balance1_dtd,0) - NVL(balance1_ctd,0)),0) paid_pmt
    FROM cn_srp_periods_all
    WHERE salesrep_id = p_salesrep_id
    AND period_id BETWEEN p_start_period_id AND p_end_period_id
    AND credit_type_id = g_credit_type_id
    AND quota_id IS NULL
    AND org_id = p_org_id;

    l_comp_earned cn_srp_periods.balance2_dtd%TYPE;
    l_converted_comp_earned cn_srp_periods.balance2_dtd%TYPE;
    l_comp_paid cn_srp_periods.balance1_dtd%TYPE;
    l_converted_comp_paid cn_srp_periods.balance1_dtd%TYPE;

    l_sum_converted_comp_earned cn_srp_periods.balance2_dtd%TYPE := 0;
    l_sum_converted_comp_paid cn_srp_periods.balance1_dtd%TYPE := 0;
    l_org_cnt NUMBER := 0;
    l_new_date_range_exists BOOLEAN := TRUE;

    l_proration_flag VARCHAR2(1);
    l_prorated_days NUMBER;
    l_total_days NUMBER;

    l_rate NUMBER; --conversion rate
    l_factor NUMBER; --proration factor

    l_from_currency gl_sets_of_books.currency_code%TYPE;
    l_conversion_date DATE;
    l_conversion_type gl_daily_conversion_types.conversion_type%TYPE;

    l_temp_org_name hr_operating_units.name%TYPE;
    l_temp_start_date DATE;
    l_temp_end_date DATE;

    l_new_start_date DATE;
    l_new_end_date DATE;

    l_api_name              CONSTANT VARCHAR2(30) := 'get_comm_and_paid_pmt';
    l_init_msg_list VARCHAR2(1);
    l_validation_level NUMBER;

BEGIN
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( g_api_version ,
                                        p_api_version ,
                                        l_api_name    ,
                                        G_PKG_NAME )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Defaults:
    l_init_msg_list := NVL(p_init_msg_list, FND_API.G_FALSE);
    l_validation_level := NVL(p_validation_level, FND_API.G_VALID_LEVEL_FULL);
    l_proration_flag := NVL(p_proration_flag, FND_API.G_FALSE);

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( l_init_msg_list )
    THEN
        FND_MSG_PUB.initialize;
    END IF;

    x_comp_earned := NULL;
    x_comp_paid := NULL;
    x_new_start_date := NULL;
    x_new_end_date := NULL;

    l_conversion_date := p_end_date;
    l_conversion_type := 'Corporate';

    get_prorated_days
    (
        p_start_date => p_start_date,
        p_end_date => p_end_date,
        x_prorated_days => l_prorated_days
    );

    FOR rec IN get_org_and_srp_id(p_person_id)
    LOOP
        l_org_cnt := l_org_cnt + 1;
        debug_msg('org_id = ' || to_char(rec.org_id) );

        get_from_currency
        (
            p_org_id => rec.org_id,
            x_from_currency => l_from_currency
        );

        IF (l_from_currency <> p_target_currency_code)
        THEN
            get_conversion_rate
            (
                p_from_currency => l_from_currency,
                p_to_currency => p_target_currency_code,
                p_conversion_date => l_conversion_date,
                p_conversion_type => l_conversion_type,
                x_rate => l_rate
            );

            --Need to raise exception if conversion rate is not available from gl.
            IF l_rate IS NULL
            THEN
                IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
                THEN
                    --CN_NO_MATCH_CORP_CONV:
                    FND_MESSAGE.SET_NAME('CN', 'CN_NO_MATCH_CORP_CONV');
                    FND_MESSAGE.SET_TOKEN('FROM_CURR',l_from_currency );
                    FND_MESSAGE.SET_TOKEN('TO_CURR',p_target_currency_code  );
                    FND_MSG_PUB.ADD;
                END IF;
                RAISE FND_API.G_EXC_ERROR;
            END IF;
        ELSIF (l_from_currency = p_target_currency_code)
        THEN
            l_rate := 1;
        END IF;

        l_comp_earned := 0;
        l_comp_paid := 0;
        --
        --Compute commission and paid payment here.
        --
        FOR pid IN get_period_ids(p_start_date, p_end_date, rec.org_id)
        LOOP
            FOR comm IN get_comm_and_pmt(rec.salesrep_id, pid.start_period_id, pid.end_period_id,rec.org_id)
            LOOP
                l_comp_earned := comm.commission;
                debug_msg('l_comp_earned = ' || to_char(l_comp_earned) );
                l_comp_paid := comm.paid_pmt;
                debug_msg('l_comp_paid = ' || to_char(l_comp_paid) );
            END LOOP;

            l_new_start_date := pid.new_start_date;
            l_new_end_date := pid.new_end_date;
            l_total_days := pid.total_days;
        END LOOP;

        --
        --Do currency conversion here.
        --
        debug_msg('l_rate = ' || to_char(l_rate) );
        l_converted_comp_earned := l_comp_earned * l_rate;
        l_converted_comp_paid := l_comp_paid * l_rate;

        --
        --Do proration.
        --
        IF l_proration_flag = FND_API.G_TRUE
        THEN
            l_factor := l_prorated_days / l_total_days;
        ELSIF l_proration_flag = FND_API.G_FALSE
        THEN
            l_factor := 1;
        END IF;
        debug_msg('l_factor = ' || to_char(l_factor) );

        l_sum_converted_comp_earned := l_sum_converted_comp_earned + l_converted_comp_earned * l_factor;
        l_sum_converted_comp_paid := l_sum_converted_comp_paid + l_converted_comp_paid * l_factor;

        --To be used in finding new date range.
        IF l_org_cnt = 1
        THEN
            l_temp_start_date := l_new_start_date;
            l_temp_end_date := l_new_end_date;
            l_temp_org_name := rec.operating_unit;
        ELSIF l_org_cnt > 1
        THEN
            --No need to raise exception if calendar setup is different
            --in different orgs.  Only push the error message to the message stack.
            IF ( (l_temp_start_date <> l_new_start_date) OR (l_temp_end_date <> l_new_end_date) )
            THEN
                l_new_date_range_exists := FALSE;

                IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
                THEN
                    --'CN_NO_MATCH_DATE_RANGE'
                    FND_MESSAGE.SET_NAME('CN', 'CN_NO_MATCH_DATE_RANGE');
                    FND_MESSAGE.SET_TOKEN('OPERATING_UNIT1',l_temp_org_name );
                    FND_MESSAGE.SET_TOKEN('OPERATING_UNIT2',rec.operating_unit );
                    FND_MSG_PUB.ADD;
                END IF;
            END IF;
        END IF;

    END LOOP;  --end of loop get_org_and_srp_id

    IF l_org_cnt = 0
    THEN
        --Need to raise exception if no salesreps are found in any orgs.
        IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
        THEN
            --'CN_NO_MATCH_SALESREP'
            FND_MESSAGE.SET_NAME('CN', 'CN_NO_MATCH_SALESREP');
            FND_MESSAGE.SET_TOKEN('PERSON_ID',to_char(p_person_id) );
            FND_MSG_PUB.ADD;
        END IF;

	    RAISE FND_API.G_EXC_ERROR;
    END IF;

    --
    --Get the compensation earned and paid.
    --
    x_comp_earned := l_sum_converted_comp_earned;
    x_comp_paid := l_sum_converted_comp_paid;

    --
    --Get the new start date and new end date
    --
    IF l_new_date_range_exists = TRUE
    THEN
        x_new_start_date := l_temp_start_date;
        x_new_end_date := l_temp_end_date;
    ELSIF l_new_date_range_exists = FALSE
    THEN
        x_new_start_date := NULL;
        x_new_end_date := NULL;
    END IF;

    -- End of API body.

    --
    -- Standard call to get message count and if count is 1, get message info.
    --
    FND_MSG_PUB.Count_And_Get
    (
        p_count   =>  x_msg_count ,
        p_data    =>  x_msg_data  ,
        p_encoded => FND_API.G_FALSE
    );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
        (
         p_count   =>  x_msg_count ,
         p_data    =>  x_msg_data  ,
         p_encoded => FND_API.G_FALSE
         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
        (
         p_count   =>  x_msg_count ,
         p_data    =>  x_msg_data   ,
         p_encoded => FND_API.G_FALSE
         );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
        (
         p_count   =>  x_msg_count ,
         p_data    =>  x_msg_data  ,
         p_encoded => FND_API.G_FALSE
         );
END get_comm_and_paid_pmt;


END CN_GET_COMM_PMT_PAID_GRP ;

/
