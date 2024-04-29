--------------------------------------------------------
--  DDL for Package Body GMP_PLNG_DTL_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMP_PLNG_DTL_REPORT_PKG" AS
/* $Header: GMPPLDRB.pls 120.13.12010000.16 2010/04/09 11:30:40 vpedarla ship $ */


   l_debug                      VARCHAR2(1) := NVL(FND_PROFILE.VALUE('GMP_DEBUG_ENABLED'),'N'); -- BUG: 9366921

   split_report                 VARCHAR2(1) := NVL(FND_PROFILE.VALUE('GMP_SPLIT_PDR_BY_ORGANIZATION'),'N'); -- Bug: 9458217 Vpedarla

   scale_report                 VARCHAR2(1) ;  -- Bug: 9265463 vpedarla

   G_inst_id                    NUMBER;
   G_org_id                     NUMBER;
--   G_plan_name                  VARCHAR2(10);
   G_plan_id                    NUMBER;
   G_plan_org                   NUMBER;
   G_start_date                 DATE;
   G_day_bucket                 NUMBER;
   G_day_bckt_cutoff_dt         DATE;
   G_plan_day_bckt_cutoff_dt    DATE;
   G_week_bucket                NUMBER;
   G_week_bckt_cutoff_dt        DATE;
   G_plan_week_bckt_cutoff_dt   DATE;
   G_period_bucket              NUMBER;
   G_fsort                      NUMBER;
   G_ssort                      NUMBER;
   G_tsort                      NUMBER;
   G_ex_typ                     NUMBER;
   G_plnr_low                   VARCHAR2(10);
   G_plnr_high                  VARCHAR2(10);
   G_byr_low                    VARCHAR2(300);
   G_byr_high                   VARCHAR2(300);
   G_itm_low                    VARCHAR2(1000);
   G_itm_high                   VARCHAR2(1000);
   G_cat_set_id                 NUMBER;
   G_category_low               VARCHAR2(300);
   G_category_high              VARCHAR2(300);
   G_abc_class_low              VARCHAR2(50);
   G_abc_class_high             VARCHAR2(50);
   G_cutoff_date                DATE;
   G_incl_items_no_activity     NUMBER ; --  Bug: 8486531 Vpedarla
   G_comb_pdr                   NUMBER;
   G_comb_pdr_temp              VARCHAR2(150);
   G_comb_pdr_locale            VARCHAR2(10);
   G_horiz_pdr                  NUMBER;
   G_horiz_pdr_temp             VARCHAR2(150);
   G_horiz_pdr_locale           VARCHAR2(10);
   G_vert_pdr                   NUMBER;
   G_vert_pdr_temp              VARCHAR2(150);
   G_vert_pdr_locale            VARCHAR2(10);
   G_excep_pdr                  NUMBER;
   G_excep_pdr_temp             VARCHAR2(150);
   G_excep_pdr_locale           VARCHAR2(10);
   G_act_pdr                    NUMBER;
   G_act_pdr_temp               VARCHAR2(150);
   G_act_pdr_locale             VARCHAR2(10);

   G_horiz_plan_stmt            VARCHAR2(32767);
   G_vert_plan_stmt             VARCHAR2(32767);
   G_exc_plan_stmt              VARCHAR2(32767);
   G_act_plan_stmt              VARCHAR2(32767);
   G_common_pdr_stmt            VARCHAR2(32767) := NULL;
   G_horiz_pdr_stmt             VARCHAR2(32767) := NULL;
   G_vert_pdr_stmt              VARCHAR2(32767) := NULL;
   G_excep_pdr_stmt             VARCHAR2(32767) := NULL;
   G_act_pdr_stmt               VARCHAR2(32767) := NULL;
   G_header_stmt                VARCHAR2(32767) := NULL;

   invalid_parameter            EXCEPTION;


-- vpedarla Bug: 8363786
 v_min_cutoff_date       DATE;
 v_hour_cutoff_date      DATE;
 v_daily_cutoff_date     DATE;
 v_weekly_cutoff_date    DATE;
 v_period_cutoff_date    DATE;
 v_err_mesg              VARCHAR2(32767);
 v_weekly_start_date     DATE ;
 v_period_start_date     DATE ;
-- vpedarla Bug: 8363786 end


-- Vpedarla bug 9366921 .
Items_count       NUMBER;

Horiz_details_count NUMBER ; -- Bug: 9265463 Vpedarla

PROCEDURE create_pdr
(
   errbuf                       OUT NOCOPY VARCHAR2,
   retcode                      OUT NOCOPY VARCHAR2,
   p_inst_id                    IN NUMBER,
   p_org_id                     IN NUMBER,
   p_plan_id                    IN NUMBER,
   p_plan_org                   IN NUMBER,
   p_start_date                 IN VARCHAR2,
   p_day_bucket                 IN NUMBER,
--   p_day_bckt_cutoff_dt         IN VARCHAR2,
   p_plan_day_bckt_cutoff_dt    IN VARCHAR2,
   p_week_bucket                IN NUMBER,
--   p_week_bckt_cutoff_dt        IN VARCHAR2,
   p_plan_week_bckt_cutoff_dt   IN VARCHAR2,
   p_period_bucket              IN NUMBER,
   p_fsort                      IN NUMBER,
   p_ssort                      IN NUMBER,
   p_tsort                      IN NUMBER,
   p_ex_typ                     IN NUMBER,
   p_plnr_low                   IN VARCHAR2,
   p_plnr_high                  IN VARCHAR2,
   p_byr_low                    IN VARCHAR2,
   p_byr_high                   IN VARCHAR2,
   p_itm_low                    IN VARCHAR2,
   p_itm_high                   IN VARCHAR2,
   p_cat_set_id                 IN NUMBER,
   p_category_low               IN VARCHAR2,
   p_category_high              IN VARCHAR2,
   p_abc_class_low              IN VARCHAR2,
   p_abc_class_high             IN VARCHAR2,
   p_cutoff_date                IN VARCHAR2,
   p_incl_items_no_activity     IN VARCHAR2, --  Bug: 8486531 Vpedarla
   p_comb_pdr                   IN NUMBER,
   p_comb_pdr_place             IN VARCHAR2,  -- Added
   p_comb_comm_pdr              IN VARCHAR2,  -- Added
   p_comb_pdr_temp              IN VARCHAR2,
   p_comb_pdr_locale            IN VARCHAR2,
   p_horiz_pdr                  IN NUMBER,
   p_horiz_pdr_place            IN VARCHAR2,  -- Added
   p_horiz_pdr_temp             IN VARCHAR2,
   p_horiz_pdr_locale           IN VARCHAR2,
   p_vert_pdr                   IN NUMBER,
   p_vert_pdr_place             IN VARCHAR2,  -- Added
   p_vert_pdr_temp              IN VARCHAR2,
   p_vert_pdr_locale            IN VARCHAR2,
   p_excep_pdr                  IN NUMBER,
   p_excep_pdr_place            IN VARCHAR2,  -- Added
   p_excep_pdr_temp             IN VARCHAR2,
   p_excep_pdr_locale           IN VARCHAR2,
   p_act_pdr                    IN NUMBER,
   p_act_pdr_place              IN VARCHAR2,  -- Added
   p_act_pdr_temp               IN VARCHAR2,
   p_act_pdr_locale             IN VARCHAR2
) IS


-- Bug: 9458217 Vpedarla
CURSOR org_select(C_plan_id in NUMBER ,C_inst_id in NUMBER , C_plan_org in NUMBER ) is
  SELECT organization_id FROM msc_plan_organizations
  WHERE plan_id = C_plan_id
  AND sr_instance_id = C_inst_id
  AND (C_plan_org = -999 or C_plan_org = organization_id ) ;

BEGIN

   gmp_debug_message(' Into GMP_PLNG_DTL_REPORT_PKG.create_pdr ');

   split_report                := NVL(FND_PROFILE.VALUE('GMP_SPLIT_PDR_BY_ORGANIZATION'),'N'); -- Bug: 9458217 Vpedarla

   scale_report                := NVL(FND_PROFILE.VALUE('GMP_SCALE_PDR'),'N'); -- Bug: 9265463 Vpedarla

   Horiz_details_count         := 0;  -- Bug: 9265463

   retcode := 0;
   G_inst_id                   := p_inst_id ;
   G_org_id                    := p_org_id ;
--   G_plan_name                 := P_plan_name ;
   G_plan_id                   := p_plan_id ;
   G_plan_org                  := p_plan_org ;
   G_start_date                := TO_DATE(p_start_date, 'YYYY/MM/DD HH24:MI:SS') ;
   G_day_bucket                := NVL(p_day_bucket,0) ;    -- 7451619 Rajesh
--   G_day_bckt_cutoff_dt        := TO_DATE(p_day_bckt_cutoff_dt, 'YYYY/MM/DD HH24:MI:SS') ;
   G_plan_day_bckt_cutoff_dt   := TO_DATE(p_plan_day_bckt_cutoff_dt, 'YYYY/MM/DD HH24:MI:SS') ;
   G_week_bucket               := NVL(p_week_bucket,0) ;   -- 7451619 Rajesh
--   G_week_bckt_cutoff_dt       := TO_DATE(p_week_bckt_cutoff_dt, 'YYYY/MM/DD HH24:MI:SS') ;
   G_plan_week_bckt_cutoff_dt  := TO_DATE(p_plan_week_bckt_cutoff_dt, 'YYYY/MM/DD HH24:MI:SS') ;
   G_period_bucket             := NVL(p_period_bucket,0) ;
   G_fsort                     := p_fsort ;
   G_ssort                     := p_ssort ;
   G_tsort                     := p_tsort ;
   G_ex_typ                    := p_ex_typ ;
   G_plnr_low                  := p_plnr_low ;
   G_plnr_high                 := p_plnr_high ;
   G_byr_low                   := p_byr_low ;
   G_byr_high                  := p_byr_high ;
   G_itm_low                   := p_itm_low ;
   G_itm_high                  := p_itm_high ;
   G_cat_set_id                := nvl(p_cat_set_id,0)   ;
   G_category_low              := p_category_low ;
   G_category_high             := p_category_high ;
   G_abc_class_low             := p_abc_class_low ;
   G_abc_class_high            := p_abc_class_high ;
   G_cutoff_date               := TO_DATE(p_cutoff_date, 'YYYY/MM/DD HH24:MI:SS') ;
   g_incl_items_no_activity    := NVL(to_number(p_incl_items_no_activity) , 1 );
   G_comb_pdr                  := NVL(p_comb_pdr,2) ;
   G_comb_pdr_temp             := p_comb_pdr_temp ;
   G_comb_pdr_locale           := p_comb_pdr_locale ;
   G_horiz_pdr                 := NVL(p_horiz_pdr,2) ;
   G_horiz_pdr_temp            := p_horiz_pdr_temp ;
   G_horiz_pdr_locale          := p_horiz_pdr_locale ;
   G_vert_pdr                  := NVL(p_vert_pdr,2) ;
   G_vert_pdr_temp             := p_vert_pdr_temp ;
   G_vert_pdr_locale           := p_vert_pdr_locale ;
   G_excep_pdr                 := NVL(p_excep_pdr,2) ;
   G_excep_pdr_temp            := p_excep_pdr_temp ;
   G_excep_pdr_locale          := p_excep_pdr_locale ;
   G_act_pdr                   := NVL(p_act_pdr,2) ;
   G_act_pdr_temp              := p_act_pdr_temp ;
   G_act_pdr_locale            := p_act_pdr_locale ;


-- Bug: 8363786 Vpedarla

  msc_snapshot_pk.get_bucket_cutoff_dates(
                           G_plan_id ,  -- p_plan_id            IN    NUMBER,
                           G_org_id ,  -- p_org_id      IN    NUMBER,
                           G_inst_id , --v_sr_instance_id,   --     IN    NUMBER,
                           G_start_date ,  --v_plan_start_date,  --     IN    DATE,
                           to_date(null), --p_plan_completion_date IN    DATE,
                           0, --p_min_cutoff_bucket   IN    number,
                           0, --p_hour_cutoff_bucket  IN    number,
                           G_day_bucket , --v_daily_cutoff_bucket, --  IN    number,
                           G_week_bucket , --v_weekly_cutoff_bucket, -- IN    number,
                           G_period_bucket , --v_period_cutoff_bucket, --  IN    number,
                           v_min_cutoff_date, --      OUT   DATE,
                           v_hour_cutoff_date, --     OUT   DATE,
                           v_daily_cutoff_date, --    OUT   DATE,
                           v_weekly_cutoff_date, --   OUT   DATE,
                           v_period_cutoff_date, --   OUT   DATE,
                           v_err_mesg --            OUT   VARCHAR2
                           ) ;

  select min(cal.week_start_date)
  into v_weekly_start_date
  from msc_cal_week_start_dates cal , msc_trading_partners mtp
  where cal.exception_set_id = mtp.calendar_exception_set_id
  and   cal.calendar_code    = mtp.calendar_code
  and   cal.week_start_date >= trunc(v_daily_cutoff_date)
  and   cal.sr_instance_id   =  G_inst_id
  and   mtp.sr_tp_id =    G_org_id
  and   mtp.partner_type  = 3
  and   cal.sr_instance_id   =  mtp.sr_instance_id ;

  select min(cal.period_start_date)
  into v_period_start_date
  from msc_period_start_dates cal , msc_trading_partners mtp
  where  cal.exception_set_id =  mtp.calendar_exception_set_id
  and   cal.calendar_code    =   mtp.calendar_code
  and   cal.period_start_date >= nvl(trunc(v_weekly_cutoff_date),trunc(v_daily_cutoff_date))
  and   cal.sr_instance_id     = G_inst_id
  and   mtp.sr_tp_id =    G_org_id
  and   mtp.partner_type  = 3
  and   cal.sr_instance_id   =  mtp.sr_instance_id ;

  if G_week_bucket = 0 and G_period_bucket = 0 and G_day_bucket = 0 then
    G_day_bckt_cutoff_dt  := G_start_date ;
    G_week_bckt_cutoff_dt := NULL;
  elsif G_week_bucket = 0 and G_period_bucket = 0  then
    G_day_bckt_cutoff_dt := v_daily_cutoff_date ;
    G_week_bckt_cutoff_dt := NULL;
  elsif G_day_bucket = 0  and G_week_bucket = 0 then
  --  G_day_bckt_cutoff_dt :=  v_period_start_date;  /*  Bug: 8447261 Vpedarla */
         G_day_bckt_cutoff_dt :=   G_start_date ;
    G_week_bckt_cutoff_dt := v_period_start_date;
  elsif G_day_bucket = 0  and G_period_bucket = 0 then
   -- G_day_bckt_cutoff_dt :=  v_weekly_start_date; /*  Bug: 8447261 Vpedarla */
     G_day_bckt_cutoff_dt :=   G_start_date ;
    G_week_bckt_cutoff_dt := v_weekly_cutoff_date + 1 ;  -- bug: 8447261
  else
    /*  Bug: 8447261 Vpedarla added the below if condition */
    if G_day_bucket = 0 THEN
      G_day_bckt_cutoff_dt := G_start_date ;
    ELSE
      G_day_bckt_cutoff_dt := v_weekly_start_date ;
    END IF;
    G_week_bckt_cutoff_dt := v_period_start_date ;
  end if;
 -- Bug: 8363786 Vpedarla end


   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' Calling GMP_PLNG_DTL_REPORT_PKG with values ');
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_inst_id '||to_char(G_inst_id));
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_org_id '||to_char(G_org_id));
--   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_plan_name '||G_plan_name);
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_plan_id '||to_char(G_plan_id));
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_plan_org '||to_char(G_plan_org));
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_start_date '||TO_CHAR(G_start_date,'DD-MON-YYYY'));
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_day_bucket '||to_char(G_day_bucket));
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_day_bckt_cutoff_dt '||TO_CHAR(G_day_bckt_cutoff_dt,'DD-MON-YYYY'));
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_plan_day_bckt_cutoff_dt '||TO_CHAR(G_plan_day_bckt_cutoff_dt,'DD-MON-YYYY'));
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_week_bucket '||to_char(G_week_bucket));
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_week_bckt_cutoff_dt '||TO_CHAR(G_week_bckt_cutoff_dt,'DD-MON-YYYY'));
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_plan_week_bckt_cutoff_dt '||TO_CHAR(G_plan_week_bckt_cutoff_dt,'DD-MON-YYYY'));
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_period_bucket '||to_char(G_period_bucket));
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_fsort '||to_char(G_fsort));
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_ssort '||to_char(G_ssort));
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_tsort '||to_char(G_tsort));
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_ex_typ '||to_char(G_ex_typ));
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_plnr_low '||G_plnr_low);
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_plnr_high '||G_plnr_high);
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_byr_low '||G_byr_low);
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_byr_high '||G_byr_high);
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_itm_low '||G_itm_low);
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_itm_high '||G_itm_high);
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_cat_set_id '||to_char(G_cat_set_id));
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_category_low '||G_category_low);
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_category_high '||G_category_high);
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_abc_class_low '||G_abc_class_low);
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_abc_class_high '||G_abc_class_high);
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_cutoff_date '||TO_CHAR(G_cutoff_date,'DD-MON-YYYY'));
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_incl_items_no_activity '||G_incl_items_no_activity);
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_comb_pdr '||to_char(G_comb_pdr));
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_comb_pdr_temp '||G_comb_pdr_temp);
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_comb_pdr_locale '||G_comb_pdr_locale);
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_vert_pdr '||to_char(G_vert_pdr));
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_vert_pdr_temp '||G_vert_pdr_temp);
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_vert_pdr_locale '||G_vert_pdr_locale);
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_horiz_pdr '||to_char(G_horiz_pdr));
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_horiz_pdr_temp '||G_horiz_pdr_temp);
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_horiz_pdr_locale '||G_horiz_pdr_locale);
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_excep_pdr '||to_char(G_excep_pdr));
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_excep_pdr_temp '||G_excep_pdr_temp);
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_excep_pdr_locale '||G_excep_pdr_locale);
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_act_pdr '||to_char(G_act_pdr));
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_act_pdr_temp '||G_act_pdr_temp);
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' G_act_pdr_locale '||G_act_pdr_locale);

   /* Bug 5708728 with the new new parameters to the report when
      combined pdr is submitted the four individual report indicators are either
      NULL or 2 thereby not printing information
      Changing them to 1 i.e. YES - this also means if combined PDR is
      submitted you can NOT turn off printing of any of the individual
      information */
      IF G_comb_pdr = 1 THEN
	G_horiz_pdr 	:= 1 ;
	G_vert_pdr 	:= 1 ;
	G_excep_pdr 	:= 1 ;
	G_act_pdr 	:= 1 ;
      END IF ;

   validate_parameters;

 IF split_report = 'Y' THEN
  FND_FILE.PUT_LINE ( FND_FILE.LOG, ' Splitting the Planning detail report on Organization basis ');
 END IF;

-- Bug: 9458217 Vpedarla setup
OPEN org_select(G_plan_id, G_inst_id, p_plan_org);
LOOP
 FETCH org_select into G_plan_org ;
 EXIT WHEN org_select%NOTFOUND ;

 IF split_report <> 'Y' THEN
  G_plan_org := p_plan_org ;
 ELSE
  FND_FILE.PUT_LINE ( FND_FILE.LOG, ' Generating report for Org id '||G_plan_org);
 END IF;

   insert_items;

   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' After insert_items ');

--     INSERT INTO temp_gmp_pdr_items_gtmp SELECT * FROM gmp_pdr_items_gtmp;

   --  Vpedarla bug: 9366921
   If Items_count > 0 THEN

	  -- Bug 9338193 Vpedarla Added the below condition.
	   IF G_horiz_pdr = 1 THEN

	     -- FND_FILE.PUT_LINE ( FND_FILE.LOG, ' Calling gmp_horizontal_pdr_pkg.populate_horizontal_plan '||
	       FND_FILE.PUT_LINE ( FND_FILE.LOG, ' Calling populate horizontal plan '||
	       ' with parameters : G_inst_id - '||to_char(G_inst_id)||' G_org_id - '||to_char(G_org_id)||
	       ' G_plan_id - '|| to_char(G_plan_id) ||
	       ' G_day_bckt_cutoff_dt - '||to_char(G_day_bckt_cutoff_dt, 'MM-DD-YYYY HH:MI:SS')||
	       ' G_week_bckt_cutoff_dt - '||to_char(G_week_bckt_cutoff_dt, 'MM-DD-YYYY HH:MI:SS')||
	       ' G_period_bucket - '||to_char(G_period_bucket));

	       -- Bug: 8486531 Vpedarla added new parameter G_incl_items_no_activity to populate_horizontal_plan procedure call.
	       gmp_horizontal_pdr_pkg.populate_horizontal_plan (G_inst_id, G_org_id, G_plan_id,
		   G_day_bckt_cutoff_dt, G_week_bckt_cutoff_dt, G_period_bucket, G_incl_items_no_activity);

	     --  FND_FILE.PUT_LINE ( FND_FILE.LOG, ' After gmp_horizontal_pdr_pkg.populate_horizontal_plan ');
	      FND_FILE.PUT_LINE ( FND_FILE.LOG, ' After populate_horizontal_plan ');
	       --     INSERT INTO temp_gmp_horizontal_pdr_gtmp SELECT * FROM gmp_horizontal_pdr_gtmp;

	       SELECT count(*) into Horiz_details_count FROM gmp_horizontal_pdr_gtmp;
	       gmp_debug_message(' Horiz_details_count = '|| Horiz_details_count );

	   ELSE

	      FND_FILE.PUT_LINE ( FND_FILE.LOG, ' Skipping populate horizontal plan ');

	   END IF;
	   -- end of Bug 9338193.

	   IF G_horiz_pdr = 1 THEN
	       horiz_plan_stmt;
	       FND_FILE.PUT_LINE ( FND_FILE.LOG, ' After horiz plan stmt ');
	   END IF;

	   IF G_vert_pdr = 1 THEN
	       vert_plan_stmt;
	       FND_FILE.PUT_LINE ( FND_FILE.LOG, ' After vert plan stmt ');
	   END IF;

	   IF G_excep_pdr = 1 THEN
	       item_exception_stmt;
	       FND_FILE.PUT_LINE ( FND_FILE.LOG, ' After item exception stmt ');
       END IF ;

       IF G_act_pdr = 1 THEN
	       item_action_stmt;
	       FND_FILE.PUT_LINE ( FND_FILE.LOG, ' After item action stmt ');
       END IF ;

	   generate_xml;
	   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' After generate xml ');

   ELSE

      FND_FILE.PUT_LINE ( FND_FILE.LOG, ' No Items are present for the given report parameters. ');

  END IF ;
    -- Vpedarla end of bug: 9366921

 IF split_report <> 'Y' THEN
  EXIT;
 END IF;

END LOOP ;
Close org_select;
-- Bug: 9458217 Vpedarla end


EXCEPTION
        WHEN OTHERS THEN
        FND_FILE.PUT_LINE ( FND_FILE.LOG,' Error in package GMP_PLNG_DTL_REPORT_PKG.CREATE_PDR - '|| sqlerrm);
        RAISE;
END create_pdr;

PROCEDURE validate_parameters IS
BEGIN
   IF G_comb_pdr = 1 THEN
      IF G_comb_pdr_temp IS NULL OR G_comb_pdr_locale IS NULL THEN
           FND_FILE.PUT_LINE(FND_FILE.LOG,'Please specify the Template and Locale for Combined Planning Detail Report ');
         RAISE invalid_parameter;
      END IF;
   ELSIF G_comb_pdr = 2 THEN
      IF G_horiz_pdr = 1 THEN
         IF G_horiz_pdr_temp IS NULL OR G_horiz_pdr_locale IS NULL THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Please specify the Template and Locale for Horizontal Planning Detail Report ');
            RAISE invalid_parameter;
         END IF;
      END IF;
      IF G_vert_pdr = 1 THEN
         IF G_vert_pdr_temp IS NULL OR G_vert_pdr_locale IS NULL THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Please specify the Template and Locale for Vertical Planning Detail Report ');
            RAISE invalid_parameter;
         END IF;
      END IF;
      IF G_excep_pdr = 1 THEN
         IF G_excep_pdr_temp IS NULL OR G_excep_pdr_locale IS NULL THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Please specify the Template and Locale for Exception Planning Detail Report ');
            RAISE invalid_parameter;
         END IF;
      END IF;
      IF G_act_pdr = 1 THEN
         IF G_act_pdr_temp IS NULL OR G_act_pdr_locale IS NULL THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Please specify the Template and Locale for Action Planning Detail Report ');
            RAISE invalid_parameter;
         END IF;
      END IF;
   END IF;
EXCEPTION
        WHEN invalid_parameter THEN
        FND_FILE.PUT_LINE ( FND_FILE.LOG,'Error in validate_parameters: Invalid Parameters submitted ');
        RAISE;
END validate_parameters;

PROCEDURE insert_items IS

 x_select               VARCHAR2(20000);
 cur_item               NUMBER;
 X_row_count            NUMBER;

BEGIN

  x_select := ' INSERT INTO gmp_pdr_items_gtmp ( '||
               '  organization_code, '||
               '  item_name, '||
               '  category_name, '||
               '  planner_code, '||
               '  buyer_name, '||
               '  abc_class_name, '||
               '  inventory_item_id, '||
               '  organization_id, '||
               '  base_item_id,  '||
               '  standard_cost, '||
               '  calculate_atp, '||
               '  wip_supply_type, '||
               '  bom_item_type '||
              '  ) '||
              ' SELECT DISTINCT '||
               '  msi.organization_code, '||
               '  msi.item_name, '||
               '  mic.category_name, '||
               '  msi.planner_code, '||
               '  msi.buyer_name, '||
               '  msi.abc_class_name, '||
               '  msi.inventory_item_id, '||
               '  msi.organization_id, '||
               '  msi.base_item_id, '||
               '  msi.standard_cost, '||
               '  msi.calculate_atp, '||
               '  msi.wip_supply_type, '||
               '  msi.bom_item_type '||
             '  FROM '||
               '   msc_system_items msi '||
               ' , msc_item_categories mic ';
  IF G_ex_typ IS NOT NULL THEN
     x_select := x_select || ' , msc_item_exceptions mie';
  END IF;

  x_select := x_select || '  WHERE '||
               '  msi.sr_instance_id = :inst_id '||
               '  AND msi.plan_id =  :plan_id '||
               '  AND mic.inventory_item_id = msi.inventory_item_id '||
               '  AND mic.organization_id = msi.organization_id '||
               '  AND mic.sr_instance_id = msi.sr_instance_id '||
               '  AND mic.category_set_id = :cat_set_id ' ;
  IF G_plan_org <> -999 THEN
     x_select := x_select || '  AND msi.organization_id = :plan_org ';
  ELSE
     x_select := x_select || '  AND msi.organization_id IN (SELECT organization_id FROM msc_plan_organizations '||
                                       '  WHERE plan_id = :plan_id AND '||
                                          ' sr_instance_id = :inst_id) ';
  END IF;
  IF G_category_low IS NOT NULL THEN
    x_select := x_select || ' AND mic.category_name >= :category_low ';
  END IF;
  IF G_category_high IS NOT NULL THEN
    x_select := x_select || ' AND mic.category_name <= :category_high ';
  END IF;
  IF G_ex_typ IS NOT NULL THEN
    x_select := x_select || ' AND msi.inventory_item_id = mie.inventory_item_id '||
               ' AND msi.organization_id = mie.organization_id '||
               ' AND msi.sr_instance_id = mie.sr_instance_id '||
               ' AND mie.exception_type = :exception_type ';
  END IF;
  IF G_plnr_low IS NOT NULL THEN
    x_select := x_select || ' AND msi.planner_code >= :planner_low ';
  END IF;
  IF G_plnr_high IS NOT NULL THEN
    x_select := x_select || ' AND msi.planner_code <= :planner_high ';
  END IF;
  IF G_byr_low IS NOT NULL THEN
    x_select := x_select || ' AND msi.buyer_name >= :buyer_low ';
  END IF;
  IF G_byr_high IS NOT NULL THEN
    x_select := x_select || ' AND msi.buyer_name <= :buyer_high ';
  END IF;
  IF G_abc_class_low IS NOT NULL THEN
    x_select := x_select || ' AND msi.abc_class_name >= :abc_class_low ';
  END IF;
  IF G_abc_class_high IS NOT NULL THEN
    x_select := x_select || ' AND msi.abc_class_name <= :abc_class_high ';
  END IF;
  IF G_itm_low IS NOT NULL THEN
    x_select := x_select || ' AND msi.item_name >= :item_name_low ';
  END IF;
  IF G_itm_high IS NOT NULL THEN
    x_select := x_select || ' AND msi.item_name <= :item_name_high ';
  END IF;

/*
  IF G_fsort IS NOT NULL THEN
    x_select := x_select || ' ORDER BY :first_sort ';
  END IF;
  IF G_ssort IS NOT NULL THEN
    x_select := x_select || ' , :second_sort ';
  END IF;
  IF G_tsort IS NOT NULL THEN
    x_select := x_select || ' , :third_sort ';
  END IF;
  IF G_fsort IS NOT NULL AND G_ssort IS NOT NULL AND G_tsort IS NOT NULL THEN
    x_select := x_select || ' ORDER BY msi.inventory_item_id, msi.organization_id ';
  END IF;
*/

  cur_item := dbms_sql.open_cursor;
  dbms_sql.parse (cur_item, x_select,dbms_sql.NATIVE);

  dbms_sql.bind_variable(cur_item, ':inst_id', G_inst_id);
  dbms_sql.bind_variable(cur_item, ':plan_id', G_plan_id);
--  dbms_sql.bind_variable(cur_item, ':plan_org', G_plan_org);
  dbms_sql.bind_variable(cur_item, ':cat_set_id', G_cat_set_id);

  IF G_plan_org <> -999 THEN
     dbms_sql.bind_variable(cur_item, ':plan_org', G_plan_org);
  END IF;

  IF G_category_low IS NOT NULL THEN
     dbms_sql.bind_variable(cur_item, ':category_low', G_category_low);
  END IF;
  IF G_category_high IS NOT NULL THEN
     dbms_sql.bind_variable(cur_item, ':category_high', G_category_high);
  END IF;

  IF G_ex_typ IS NOT NULL THEN
     dbms_sql.bind_variable(cur_item, ':exception_type', G_ex_typ);
  END IF;

  IF G_plnr_low IS NOT NULL THEN
     dbms_sql.bind_variable(cur_item, ':planner_low', G_plnr_low);
  END IF;
  IF G_plnr_high IS NOT NULL THEN
     dbms_sql.bind_variable(cur_item, ':planner_high', G_plnr_high);
  END IF;

  IF G_byr_low IS NOT NULL THEN
     dbms_sql.bind_variable(cur_item, ':buyer_low', G_byr_low);
  END IF;
  IF G_byr_high IS NOT NULL THEN
     dbms_sql.bind_variable(cur_item, ':buyer_high', G_byr_high);
  END IF;

  IF G_abc_class_low IS NOT NULL THEN
     dbms_sql.bind_variable(cur_item, ':abc_class_low', G_abc_class_low);
  END IF;
  IF G_abc_class_high IS NOT NULL THEN
     dbms_sql.bind_variable(cur_item, ':abc_class_high', G_abc_class_high);
  END IF;

  IF G_itm_low IS NOT NULL THEN
      dbms_sql.bind_variable(cur_item, ':item_name_low', G_itm_low);
  END IF;
  IF G_itm_high IS NOT NULL THEN
      dbms_sql.bind_variable(cur_item, ':item_name_high', G_itm_high);
  END IF;
/*
  IF G_fsort IS NOT NULL THEN
      dbms_sql.bind_variable(cur_item, ':first_sort', G_fsort);
  END IF;
  IF G_ssort IS NOT NULL THEN
      dbms_sql.bind_variable(cur_item, ':second_sort', G_ssort);
  END IF;
  IF G_tsort IS NOT NULL THEN
      dbms_sql.bind_variable(cur_item, ':third_sort', G_tsort);
  END IF;
*/

  FND_FILE.PUT_LINE(FND_FILE.LOG,' Item query - '||x_select );

  X_row_count := dbms_sql.EXECUTE (cur_item);

  -- Vpedarla bug: 9366921
  Items_count := X_row_count ;

  FND_FILE.PUT_LINE(FND_FILE.LOG,'Num of rows in gmp_pdr_items_gtmp '||to_char(X_row_count));

  dbms_sql.close_cursor (cur_item);

EXCEPTION
   WHEN OTHERS THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Error in package GMP_PLNG_DTL_REPORT_PKG '||sqlerrm);
      IF dbms_sql.is_open (cur_item) THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'EXCEPTION cur_item is Open');
        dbms_sql.close_cursor (cur_item);
      END IF;
END insert_items;


PROCEDURE horiz_plan_stmt IS

BEGIN

  G_horiz_plan_stmt :=   ' SELECT '||
        ' organization_id ,  '||
        ' inventory_item_id ,  '||
        ' bucket_date ,  '||
        ' quantity1 , '||
        ' quantity2 , '||
        ' quantity3 , '||
        ' quantity4 , '||
        ' quantity5 , '||
        ' quantity6 , '||
        ' quantity7 , '||
        ' quantity8 , '||
        ' quantity9 , '||
        ' quantity10 , '||
        ' quantity11 , '||
        ' quantity12 , '||
        ' quantity13 , '||
        ' quantity14 , '||
        ' quantity15 , '||
        ' quantity16 , '||
        ' quantity17 , '||
        ' quantity18 , '||
        ' quantity19 , '||
   --     ' quantity20 , '||
   --     ' quantity21 , '||
        ' quantity22 '||
   --     ' quantity23 , '||
   --     ' quantity24 , '||
   --     ' quantity25 , '||
   --     ' quantity26 , '||
   --     ' quantity27 , '||
   --     ' quantity28 , '||
   --     ' quantity29 , '||
   --     ' quantity30 , '||
   --     ' quantity31 , '||
   --     ' quantity32 , '||
   --     ' quantity33 , '||
   --     ' quantity34 , '||
   --     ' quantity35 , '||
   --     ' quantity36 , '||
   --     ' quantity37 , '||
   --     ' quantity38 , '||
   --     ' quantity39 , '||
   --     ' quantity40 , '||
   --     ' quantity41 , '||
   --     ' quantity42 , '||
   --     ' quantity43 , '||
   --     ' quantity44 , '||
   --     ' quantity45  '||
 ' FROM '||
    ' ( SELECT '||
           ' ghp.organization_id ,  '||
           ' ghp.inventory_item_id ,  '||
           ' ghp.bucket_date ,  '||
           ' ghp.quantity1 , '||
           ' ghp.quantity2 , '||
           ' ghp.quantity3 , '||
           ' ghp.quantity4 , '||
           ' ghp.quantity5 , '||
           ' ghp.quantity6 , '||
           ' ghp.quantity7 , '||
           ' ghp.quantity8 , '||
           ' ghp.quantity9 , '||
           ' ghp.quantity10 , '||
           ' ghp.quantity11 , '||
           ' ghp.quantity12 , '||
           ' ghp.quantity13 , '||
           ' ghp.quantity14 , '||
           ' ghp.quantity15 , '||
           ' ghp.quantity16 , '||
           ' ghp.quantity17 , '||
           ' ghp.quantity18 , '||
           ' ghp.quantity19 , '||
       --    ' ghp.quantity20 , '||
       --    ' ghp.quantity21 , '||
           ' ghp.quantity22 '||
       --    ' ghp.quantity23 , '||
       --    ' ghp.quantity24 , '||
       --    ' ghp.quantity25 , '||
       --    ' ghp.quantity26 , '||
       --    ' ghp.quantity27 , '||
       --    ' ghp.quantity28 , '||
       --    ' ghp.quantity29 , '||
       --    ' ghp.quantity30 , '||
       --    ' ghp.quantity31 , '||
       --    ' ghp.quantity32 , '||
       --    ' ghp.quantity33 , '||
       --    ' ghp.quantity34 , '||
       --    ' ghp.quantity35 , '||
       --    ' ghp.quantity36 , '||
       --    ' ghp.quantity37 , '||
       --    ' ghp.quantity38 , '||
       --    ' ghp.quantity39 , '||
       --    ' ghp.quantity40 , '||
       --    ' ghp.quantity41 , '||
       --    ' ghp.quantity42 , '||
       --    ' ghp.quantity43 , '||
       --    ' ghp.quantity44 , '||
       --    ' ghp.quantity45  '||
    ' FROM '||
           ' gmp_horizontal_pdr_gtmp ghp ) ';

EXCEPTION
   WHEN OTHERS THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Error in procedure item_exception_stmt '||sqlerrm);
END horiz_plan_stmt;

PROCEDURE vert_plan_stmt IS

BEGIN

  G_vert_plan_stmt :=
  ' SELECT '||
        ' organization_code,  '|| /* header show */
        ' item_name,  '|| /* header show */
        ' category_name,   '|| /* header show */
        ' planner_code,  '|| /* header show */
        ' buyer_name,  '|| /* header show */
        ' abc_class_name,  '|| /* header show */
        ' planning_group,  '||
        ' order_type,  '||/* detail show */
        ' order_number,  '||/* detail show */
        ' activity_date,  '||/* detail show */
        ' quantity_rate,  '||/* detail show */
        ' old_schd_date, '||
        ' order_placement_date,  '||
        ' new_schedule_date,  '||
        ' new_doc_date,  '||
        ' new_wip_start_date,  '||
        ' implement_as_id, '||
        ' firm_date,  '||
        ' firm_qty, '||
        ' wip_qty, '||
        ' compression_days,  '||
        ' using_assembly_item_name, '||
        ' designator, '||
        ' source_org, '||
        ' supplier_name, '||
        ' plan_name,  '||
        ' plan_id, '||
        ' organization_id,  '||
        ' sr_instance_id,  '||
        ' cat_set_id, ' ||-- mic.category_set_id, /* Global Var */
        ' inventory_item_id, '||
        ' supplier_id,  '||
        ' implement_as, '||
        ' implemented_qty '||
  ' FROM '||
     '( SELECT '||
           ' gpi.organization_code organization_code,  '|| /* header show */
           ' gpi.item_name item_name,  '|| /* header show */
           ' gpi.category_name category_name,   '|| /* header show */
           ' gpi.planner_code planner_code,  '|| /* header show */
           ' gpi.buyer_name buyer_name,  '|| /* header show */
           ' gpi.abc_class_name abc_class_name,  '|| /* header show */
           ' sup.planning_group planning_group,  '||
           ' l1.meaning order_type,  '||/* detail show */
           ' DECODE (sup.order_type, '||
                  ' 5, TO_CHAR (sup.transaction_id), '||
                  ' sup.order_number '||
                  ' ) order_number,  '||/* detail show */
           ' cal.calendar_date activity_date,  '||/* detail show */
           ' NVL (sup.daily_rate, sup.new_order_quantity) quantity_rate,  '||/* detail show */
           ' sup.old_schedule_date old_schd_date, '||
           ' sup.new_order_placement_date order_placement_date,  '||
           ' sup.new_schedule_date new_schedule_date,  '||
           ' sup.new_dock_date new_doc_date,  '||
           ' sup.new_wip_start_date new_wip_start_date,  '||
           ' sup.implement_as implement_as_id, '||
           ' sup.firm_date firm_date,  '||
           ' sup.firm_quantity firm_qty, '||
           ' NVL (sup.daily_rate, sup.new_order_quantity) - NVL (sup.quantity_in_process, 0) wip_qty, '||
           ' sup.schedule_compress_days compression_days,  '||
           ' TO_CHAR (NULL) using_assembly_item_name, '||
           ' msc_get_name.designator (sup.schedule_designator_id) designator, '||
   --        ' msc_get_name.designator (sup.schedule_designator_id), /* Since this column is selected twice, so removing one instance. */
           ' msc_get_name.org_code (sup.source_organization_id, '||
                                 ' sup.source_sr_instance_id '||
                                 ' )  source_org, '||
           ' msc_get_name.supplier (DECODE (sup.plan_id, '||
                                         ' -1, sup.supplier_id, '||
                                         ' DECODE (sup.order_type, '||
                                                 ' 1, sup.supplier_id, '||
                                                 ' 2, sup.supplier_id, '||
                                                 ' sup.source_supplier_id '||
                                                ' ) '||
                                        ' ) '||
                                ' ) supplier_name, '||
           ' mp.compile_designator plan_name,  '||
           ' sup.plan_id plan_id, '||
           ' sup.organization_id organization_id,  '||
           ' sup.sr_instance_id sr_instance_id,  '||
           ' '||G_cat_set_id||' cat_set_id, ' ||-- mic.category_set_id, /* Global Var */
           ' sup.inventory_item_id inventory_item_id, '||
           ' sup.supplier_id supplier_id,  '||
           ' DECODE (sup.implement_as, '||
                  ' NULL, NULL, '||
                  ' msc_get_name.lookup_meaning ('||''''||'MRP_WORKBENCH_IMPLEMENT_AS'||''''||', '||
                                               ' sup.implement_as '||
                                              ' ) '||
                  ' ) implement_as, '||
           ' DECODE (sup.disposition_status_type, '||
                  ' 2, 0.0, '||
                  ' NVL (sup.daily_rate, sup.new_order_quantity) '||
                 ' ) implemented_qty '||
    ' FROM '||
   --       msc_item_categories mic,
   --      '  msc_system_items msi,
           ' gmp_pdr_items_gtmp gpi, '||
           ' msc_supplies sup, '||
           ' msc_trading_partners mtp, '||
           ' msc_calendar_dates cal, '||
           ' mfg_lookups l1, '||
           ' msc_plans mp '||
    ' WHERE cal.calendar_date BETWEEN TRUNC (sup.new_schedule_date) '||
                               ' AND NVL (TRUNC (sup.last_unit_completion_date), '||
                                        ' TRUNC (sup.new_schedule_date) '||
                                       ' ) '||
           ' AND DECODE (sup.last_unit_completion_date, NULL, 1, cal.seq_num) IS NOT NULL '||
           ' AND cal.exception_set_id = mtp.calendar_exception_set_id '||
           ' AND cal.calendar_code = mtp.calendar_code '||
           ' AND cal.sr_instance_id = mtp.sr_instance_id '||
           ' AND mtp.sr_tp_id = sup.organization_id '||
           ' AND mtp.sr_instance_id = sup.sr_instance_id '||
           ' AND mtp.partner_type = 3 '||
           ' AND sup.plan_id = '||G_plan_id||-- msi.plan_id /* Global Var */
           ' AND sup.sr_instance_id = '||G_inst_id||-- msi.sr_instance_id /* Global Var */
           ' AND sup.organization_id = gpi.organization_id '||
           ' AND sup.inventory_item_id = gpi.inventory_item_id '||
           ' AND NVL (sup.daily_rate, sup.new_order_quantity) <> 0 '||
           ' AND l1.lookup_type = '||''''||'MRP_ORDER_TYPE'||''''||
           ' AND l1.lookup_code = sup.order_type '||
           ' AND mp.plan_id = sup.plan_id '||
           ' AND TRUNC (cal.calendar_date) <= (NVL (TRUNC(TO_DATE('||''''||TO_CHAR(G_cutoff_date, 'YYYY/MM/DD HH24:MI:SS')||''''||', '||''''||'YYYY/MM/DD HH24:MI:SS'||''''||')), TRUNC (cal.calendar_date))) '||
           /* Global Var */
    ' UNION ALL '||
    ' SELECT  '||
           ' gpi.organization_code organization_code,  '|| /* header show */
           ' gpi.item_name item_name, '|| /* header show */
           ' gpi.category_name category_name,  '|| /* header show */
           ' gpi.planner_code planner_code,  '|| /* header show */
           ' gpi.buyer_name buyer_name,  '|| /* header show */
           ' gpi.abc_class_name abc_class_name,  '|| /* header show */
           ' dem.planning_group planning_group,  '||
           ' l1.meaning order_type,  '||/* detail show */
           ' NVL (dem.order_number, '||
               ' DECODE (dem.origination_type, '||
                       ' 29, msc_get_name.scenario_designator (dem.forecast_set_id, '||
                                                             ' dem.plan_id, '||
                                                             ' dem.organization_id, '||
                                                             ' dem.sr_instance_id '||
                                                           ' ), '||
                       ' msc_get_name.designator (dem.schedule_designator_id) '||
                      ' ) '||
              ' ) order_number ,  '||/* detail show */
           ' cal.calendar_date activity_date ,  '||/* detail show */
           ' -NVL (dem.daily_demand_rate, dem.using_requirement_quantity) quantity_rate,  '||/* detail show */
           ' dem.old_demand_date old_schd_date,  '||
           ' TO_DATE (NULL) order_placement_date,  '||
           ' dem.using_assembly_demand_date new_schedule_date,  '||
           ' TO_DATE (NULL) new_doc_date,  '||
           ' TO_DATE (NULL) new_wip_start_date,  '||
           ' TO_NUMBER (NULL)implement_as_id,  '||
           ' dem.firm_date firm_date, '||
           ' dem.firm_quantity firm_qty, '||
           ' -NVL (dem.daily_demand_rate, dem.using_requirement_quantity) - TO_NUMBER (NULL) wip_qty, '||
           ' TO_NUMBER (NULL) compression_days, '||
           ' msc_get_name.item_name (dem.using_assembly_item_id, NULL, NULL, NULL) using_assembly_item_name, '||
           ' DECODE (dem.schedule_designator_id, '||
                  ' NULL, NULL, '||
                  ' DECODE (dem.origination_type, '||
                          ' 29, msc_get_name.forecastsetname (dem.forecast_set_id, '||
                                                            ' dem.plan_id, '||
                                                            ' dem.organization_id, '||
                                                            ' dem.sr_instance_id '||
                                                           ' ), '||
                           ' msc_get_name.designator (dem.schedule_designator_id) '||
                         ' ) '||
                 ' ) designator, '||
   /*        DECODE (dem.schedule_designator_id,
                   NULL, NULL,
                   DECODE (dem.origination_type,
                           29, msc_get_name.forecastsetname (dem.forecast_set_id,
                                                             dem.plan_id,
                                                             dem.organization_id,
                                                             dem.sr_instance_id
                                                            ),
                           msc_get_name.designator (dem.schedule_designator_id)
                          )
                  ), */ /* Since this column is selected twice, so removing one instance. */
           ' msc_get_name.org_code (dem.source_organization_id, '||
                                 ' dem.source_org_instance_id '||
                                ' ) source_org, '||
           ' NULL supplier_name,  '||
           ' mp.compile_designator plan_name,  '||
           ' dem.plan_id plan_id, '||
           ' dem.organization_id organization_id,  '||
           ' dem.sr_instance_id sr_instance_id,  '||
           ' '||G_cat_set_id||' cat_set_id, '||-- mic.category_set_id,  /* Global Var */
           ' dem.inventory_item_id inventory_item_id, '||
           ' TO_NUMBER (NULL) supplier_id,  '||
           ' TO_CHAR (NULL) implement_as, '||
           ' -NVL (dem.daily_demand_rate, dem.using_requirement_quantity) implemented_qty '||
    ' FROM  '||
    -- msc_item_categories mic,
   --      ' msc_system_items msi,
           ' gmp_pdr_items_gtmp gpi, '||
           ' msc_demands dem, '||
           ' msc_trading_partners mtp, '||
           ' msc_calendar_dates cal, '||
           ' mfg_lookups l1, '||
           ' msc_plans mp '||
    ' WHERE cal.calendar_date BETWEEN TRUNC (dem.using_assembly_demand_date) '||
                               ' AND NVL (TRUNC (dem.assembly_demand_comp_date), '||
                                        ' TRUNC (dem.using_assembly_demand_date) '||
                                       ' ) '||
           ' AND DECODE (dem.assembly_demand_comp_date, NULL, 1, cal.seq_num) IS NOT NULL '||
           ' AND cal.exception_set_id = mtp.calendar_exception_set_id '||
           ' AND cal.calendar_code = mtp.calendar_code '||
           ' AND cal.sr_instance_id = mtp.sr_instance_id '||
           ' AND mtp.sr_tp_id = dem.organization_id '||
           ' AND mtp.sr_instance_id = dem.sr_instance_id '||
           ' AND mtp.partner_type = 3 '||
           ' AND dem.plan_id = '||G_plan_id||-- msi.plan_id /* Global Var */
           ' AND dem.sr_instance_id = '||G_inst_id||-- msi.sr_instance_id /* Global Var */
           ' AND dem.organization_id = gpi.organization_id '||
           ' AND dem.inventory_item_id = gpi.inventory_item_id '||
           ' AND NVL (dem.daily_demand_rate, dem.using_requirement_quantity) <> 0 '||
           ' AND l1.lookup_type = '||''''||'MSC_DEMAND_ORIGINATION'||''''||
           ' AND l1.lookup_code = dem.origination_type '||
           ' AND mp.plan_id = dem.plan_id '||
           ' AND TRUNC (cal.calendar_date) <= (NVL (TRUNC(TO_DATE('||''''||TO_CHAR(G_cutoff_date, 'YYYY/MM/DD HH24:MI:SS')||''''||', '||''''||'YYYY/MM/DD HH24:MI:SS'||''''||')), TRUNC (cal.calendar_date)))  )';
           /* Global Var */

EXCEPTION
   WHEN OTHERS THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Error in procedure vert_plan_stmt '||sqlerrm);
END vert_plan_stmt;

PROCEDURE item_exception_stmt IS

BEGIN

  G_exc_plan_stmt :=
  ' SELECT '||
        ' organization_code, '||
        ' item_name,  '||
        ' category_name,  '|| /* header show */
        ' planner_code,  '|| /* header show */
        ' buyer_name,  '|| /* header show */
        ' abc_class_name,  '|| /* header show */
        ' exception_id, '||
        ' inventory_item_id, '||
        ' organization_id, '||
        ' exception_type exception_type_dtl , '|| -- Vpedarla bug:7408259 Modified the column alias since the header statement also has same column name
        ' exception_type_text, '||
        ' due_date, '||
        ' quantity, '||
        ' from_date, '||
        ' to_date, '||
        ' lot_number, '||
        ' department_line_code'||
  ' FROM '||
     '( SELECT '||
           ' med.organization_code organization_code, '||
           ' gpi.item_name item_name,  '||
           ' gpi.category_name category_name,  '|| /* header show */
           ' gpi.planner_code planner_code,  '|| /* header show */
           ' gpi.buyer_name buyer_name,  '|| /* header show */
           ' gpi.abc_class_name abc_class_name,  '|| /* header show */
           ' med.exception_id exception_id, '||
           ' gpi.inventory_item_id inventory_item_id, '||
           ' gpi.organization_id organization_id, '||
           ' med.exception_type exception_type, '||
           ' med.exception_type_text exception_type_text, '||
           ' med.due_date due_date, '||
           ' med.quantity quantity, '||
           ' med.from_date from_date, '||
           ' med.to_date to_date, '||
           ' med.lot_number lot_number, '||
           ' med.department_line_code department_line_code'||
    ' FROM msc_exception_details_v med, '||
           ' gmp_pdr_items_gtmp gpi '||
           ' WHERE med.plan_id = '||G_plan_id||
   -- Bug: 7257708 Vpedarla changed the below two lines
   -- ' WHERE med.exception_type IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,20,24,26,30) '||
   --        ' AND TRUNC (med.to_date) <= (NVL (TRUNC(TO_DATE('||''''||TO_CHAR(G_cutoff_date, 'YYYY/MM/DD HH24:MI:SS')||''''||', '||''''||'YYYY/MM/DD HH24:MI:SS'||''''||')), TRUNC (med.to_date)))  '||
   ' AND TRUNC (nvl(med.to_date,sysdate)) <= (NVL (TRUNC(TO_DATE('||''''||TO_CHAR(G_cutoff_date, 'YYYY/MM/DD HH24:MI:SS')||''''||', '||''''||'YYYY/MM/DD HH24:MI:SS'||''''||')), TRUNC (nvl(med.to_date,sysdate))))  '||
           /* Global Var */
           ' AND med.sr_instance_id = '||G_inst_id||
           ' AND med.inventory_item_id = gpi.inventory_item_id '||
           ' AND nvl(med.category_set_id, '||G_cat_set_id ||') = '|| G_cat_set_id ||
           ' AND med.organization_id = gpi.organization_id  )' ;
EXCEPTION
   WHEN OTHERS THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Error in procedure item_exception_stmt '||sqlerrm);
END item_exception_stmt;

PROCEDURE item_action_stmt IS

BEGIN

  G_act_plan_stmt :=
  ' SELECT '||
        ' inventory_item_id, '||
        ' organization_id, '||
        ' item_action, '||
        ' order_type, '||
        ' order_number, '||
        ' activity_date, '||
        ' old_schedule_date, '||
        ' new_order_placement_date, '||
        ' new_schedule_date, '||
        ' new_dock_date, '||
        ' new_wip_start_date, '||
        ' schedule_compress_days '||
  ' FROM '||
  '    ( SELECT '||
        '    gpi.inventory_item_id, '||
        '    gpi.organization_id, '||
        '    DECODE  '||
        '    ( '||
        '       msc_get_name.action  '||
        '       ( '||
        '          '||''''||'MSC_SUPPLIES'||''''||' ,  '||
        '          gpi.bom_item_type, '||
        '          gpi.base_item_id, '||
        '          gpi.wip_supply_type, '||
        '          sup.order_type, '||
        '          DECODE (sup.firm_planned_type,1, 1,sup.reschedule_flag), '||
        '          sup.disposition_status_type, '||
        '          sup.new_schedule_date, '||
        '          sup.old_schedule_date, '||
        '          sup.implemented_quantity, '||
        '          sup.quantity_in_process, '||
        '          DECODE (sup.new_order_quantity,0, sup.firm_quantity,sup.new_order_quantity) '||
        '       ), '||
        '       '||''''||'None'||''''||' , DECODE  '||
        '       ( '||
        '          SIGN (sup.new_schedule_date - sup.old_schedule_date), '||
        '          1, msc_get_name.lookup_meaning ('||''''||'MRP_ACTIONS'||''''||' ,3), '||
        '          -1, msc_get_name.lookup_meaning ('||''''||'MRP_ACTIONS'||''''||' ,2), '||
        '         '||''''||'None'||''''||
        '       ), '||
        '       msc_get_name.action  '||
        '       ( '||
        '          '||''''||'MSC_SUPPLIES'||''''||' , '||
        '          gpi.bom_item_type, '||
        '          gpi.base_item_id, '||
        '          gpi.wip_supply_type, '||
        '          sup.order_type, '||
        '          DECODE (sup.firm_planned_type,1, 1,sup.reschedule_flag), '||
        '          sup.disposition_status_type, '||
        '          sup.new_schedule_date, '||
        '          sup.old_schedule_date, '||
        '          sup.implemented_quantity, '||
        '          sup.quantity_in_process, '||
        '          DECODE (sup.new_order_quantity,0, sup.firm_quantity,sup.new_order_quantity) '||
        '       ) '||
        '    ) item_action, '||
        '    l1.meaning order_type, '||
        '    DECODE (sup.order_type,5, TO_CHAR (sup.transaction_id),sup.order_number) order_number, '||
        '    cal.calendar_date activity_date, '||
        '    sup.old_schedule_date old_schedule_date, '||
        '    sup.new_order_placement_date new_order_placement_date,  '||
        '    sup.new_schedule_date new_schedule_date, '||
        '    sup.new_dock_date new_dock_date,  '||
        '    sup.new_wip_start_date new_wip_start_date,  '||
        '    sup.schedule_compress_days schedule_compress_days '||
  '    FROM  '||
        '    gmp_pdr_items_gtmp gpi, '||
        '    msc_supplies sup, '||
        '    msc_calendar_dates cal, '||
        '    msc_trading_partners mtp, '||
        '    mfg_lookups l1 '||
  '    WHERE '||
        '    cal.calendar_date BETWEEN TRUNC (sup.new_schedule_date) '||
        '                              AND NVL (TRUNC (sup.last_unit_completion_date), '||
        '                                       TRUNC (sup.new_schedule_date) '||
        '                                      ) '||
        '    AND DECODE (sup.last_unit_completion_date, NULL, 1, cal.seq_num) IS NOT NULL '||
        '    AND cal.exception_set_id = mtp.calendar_exception_set_id '||
        '    AND cal.calendar_code = mtp.calendar_code '||
        '    AND cal.sr_instance_id = mtp.sr_instance_id '||
        '    AND mtp.sr_tp_id = sup.organization_id '||
        '    AND mtp.sr_instance_id = sup.sr_instance_id '||
        '    AND mtp.partner_type = 3 '||
        '    AND sup.plan_id = '||G_plan_id|| -- gpi.plan_id /* Global Var */
        '    AND sup.sr_instance_id = '||G_inst_id|| -- gpi.sr_instance_id /* Global Var */
        '    AND sup.organization_id = gpi.organization_id '||
        '    AND sup.inventory_item_id = gpi.inventory_item_id '||
        '    AND NVL (sup.daily_rate, sup.new_order_quantity) <> 0 '||
        '    AND l1.lookup_type = '||''''||'MRP_ORDER_TYPE'||''''||
        '    AND l1.lookup_code = sup.order_type '||
        '    AND TRUNC (cal.calendar_date) <= (NVL (TRUNC(TO_DATE('||''''||TO_CHAR(G_cutoff_date, 'YYYY/MM/DD HH24:MI:SS')||''''||', '||''''||'YYYY/MM/DD HH24:MI:SS'||''''||')), TRUNC (cal.calendar_date))) ) ';

EXCEPTION
   WHEN OTHERS THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Error in procedure item_action_stmt '||sqlerrm);
END item_action_stmt;

PROCEDURE generate_xml IS

   qryCtx                 DBMS_XMLGEN.ctxHandle;
   result                 CLOB;
   seq_stmt               VARCHAR2(100);
   x_seq_num              NUMBER;
   l_encoding             VARCHAR2(20);  /* B7481907 */
   l_xml_header           VARCHAR2(100); /* B7481907 */
   l_offset               PLS_INTEGER;   /* B7481907 */
   temp_clob              CLOB;          /* B7481907 */
   l_ref_cur              SYS_REFCURSOR; /* B7481907 */
   len                    PLS_INTEGER;   /* B7481907 */

BEGIN

   seq_stmt                     := NULL;
   x_seq_num                    := 0;

    -- B7481907 Rajesh Patangya starts
    -- The following line of code ensures that XML data
    -- generated here uses the right encoding
        l_encoding       := fnd_profile.value('ICX_CLIENT_IANA_ENCODING');
        l_xml_header     := '<?xml version="1.0" encoding="'|| l_encoding ||'"?>';
        FND_FILE.PUT_LINE(FND_FILE.LOG,'l_xml_header - '||l_xml_header);
    -- B7481907 Rajesh Patangya starts

   G_header_stmt := ' SELECT ' ||
           ' msc_get_name.org_code ('||G_org_id||', '||G_inst_id||' )  master_org, '||
           ' msc_get_name.instance_code ('||G_inst_id||' )  instance_code, '||
--           ''''||G_plan_name||''''||' plan_name, ' ||
           ' gmp_plng_dtl_report_pkg.plan_name plan_name, '||
           ' gmp_plng_dtl_report_pkg.plan_org ('||G_plan_org||' ) plan_org, '||
           G_day_bucket||' day_bucket, '||
           G_week_bucket||' week_bucket, '||
           G_period_bucket||' period_bucket, ';

   IF G_fsort IS NOT NULL THEN
      G_header_stmt := G_header_stmt ||
           ' gmp_plng_dtl_report_pkg.lookup_meaning ('||''''||'GMP_DATA_SELECT'||''''||', '||G_fsort||' ) first_sort, ';
   ELSE
      G_header_stmt := G_header_stmt ||
           ''''||G_fsort||''''||' first_sort, ';
   END IF;

   IF G_ssort IS NOT NULL THEN
      G_header_stmt := G_header_stmt ||
           ' gmp_plng_dtl_report_pkg.lookup_meaning ('||''''||'GMP_DATA_SELECT'||''''||', '||G_ssort||' ) second_sort, ';
   ELSE
      G_header_stmt := G_header_stmt ||
           ''''||G_ssort||''''||' second_sort, ';
   END IF;

   IF G_tsort IS NOT NULL THEN
      G_header_stmt := G_header_stmt ||
           ' gmp_plng_dtl_report_pkg.lookup_meaning ('||''''||'GMP_DATA_SELECT'||''''||', '||G_tsort||' ) third_sort, ';
   ELSE
      G_header_stmt := G_header_stmt ||
           ''''||G_tsort||''''||' third_sort, ' ;
   END IF;

   IF G_ex_typ IS NOT NULL THEN
      G_header_stmt := G_header_stmt ||
  --  Bug: 7257708 Vpedarla changed the below line.
  --         ' msc_get_name.lookup_meaning ('||''''||'MSC_X_EXCEPTION_TYPE'||''''||', '||G_ex_typ||' ) exception_type, ';
          ' msc_get_name.lookup_meaning ('||''''||'MRP_EXCEPTION_CODE_TYPE'||''''||', '||G_ex_typ||' ) exception_type, ';
   ELSE
      -- Vpedarla bug: 7408259 Modified the below code
    /*  G_header_stmt := G_header_stmt ||
           ''''||G_ex_typ||''''||' exception_type, ' ;  */
        G_header_stmt := G_header_stmt ||
           ''''||'ALL'||''''||' exception_type, ' ;
   END IF;

   G_header_stmt := G_header_stmt ||''''||G_plnr_low||''''||' planner_low, ' ||
           ''''||G_plnr_high||''''||' planner_high, ' ||
           ''''||G_byr_low||''''||' buyer_low, ' ||
           ''''||G_byr_high||''''||' buyer_high, ' ||
           ''''||G_itm_low||''''||' item_low, ' ||
           ''''||G_itm_high||''''||' item_high, ' ||
           ' gmp_plng_dtl_report_pkg.category_set_name ('||G_cat_set_id||' ) category_set_name, '||
           /* ToDo : define the function category_set_name */
           ''''||G_category_low||''''||' category_low, ' ||
           ''''||G_category_high||''''||' category_high, ' ||
           ''''||G_abc_class_low||''''||' abc_class_low, ' ||
           ''''||G_abc_class_high||''''||' abc_class_high, ' ||
           ''''||G_cutoff_date||''''||' cutoff_date, ' ||
           ' msc_get_name.lookup_meaning ('||''''||'SYS_YES_NO'||''''||', '||G_incl_items_no_activity||' ) INCL_ITEMS_NO_ACTIVITY, '||  --8486531 Vpedarla
           ' msc_get_name.lookup_meaning ('||''''||'SYS_YES_NO'||''''||', '||G_comb_pdr||' ) comb_pdr, '||
           ''''||G_comb_pdr_temp||''''||' comb_pdr_temp, ' ||
           ''''||G_comb_pdr_locale||''''||' comb_pdr_locale, ' ||
           ' msc_get_name.lookup_meaning ('||''''||'SYS_YES_NO'||''''||', '||G_horiz_pdr||' ) horiz_pdr, '||
           ''''||G_horiz_pdr_temp||''''||' horiz_pdr_temp, ' ||
           ''''||G_horiz_pdr_locale||''''||' horiz_pdr_locale, ' ||
           ' msc_get_name.lookup_meaning ('||''''||'SYS_YES_NO'||''''||', '||G_vert_pdr||' ) vert_pdr, '||
           ''''||G_vert_pdr_temp||''''||' vert_pdr_temp, ' ||
           ''''||G_vert_pdr_locale||''''||' vert_pdr_locale, ' ||
           ' msc_get_name.lookup_meaning ('||''''||'SYS_YES_NO'||''''||', '||G_excep_pdr||' ) excep_pdr, '||
           ''''||G_excep_pdr_temp||''''||' excep_pdr_temp, ' ||
           ''''||G_excep_pdr_locale||''''||' excep_pdr_locale, ' ||
           ' msc_get_name.lookup_meaning ('||''''||'SYS_YES_NO'||''''||', '||G_act_pdr||' ) act_pdr, '||
           ''''||G_act_pdr_temp||''''||' act_pdr_temp, ' ||
           ''''||G_act_pdr_locale||''''||' act_pdr_locale ';

   IF G_comb_pdr = 1	THEN	/*combined pdr report */

      G_common_pdr_stmt := NULL ;

--       INSERT INTO ns_debug (LONGVAL) values ('in combined PDR');
      FND_FILE.PUT_LINE(FND_FILE.LOG,'in combined PDR');

      G_common_pdr_stmt := G_common_pdr_stmt || G_header_stmt;

  -- Vpedarla bug: 8273098 modified the order of columns based on order by clause from parameters.
      G_common_pdr_stmt := G_common_pdr_stmt || ' , CURSOR ( SELECT  gpi.organization_code organization_code, gpi.item_name item_name, '||
         ' gpi.category_name category_name, gpi.planner_code planner_code, gpi.buyer_name buyer_name,  gpi.abc_class_name abc_class_name';

      IF G_horiz_pdr = 1 THEN
         BEGIN
            G_common_pdr_stmt := G_common_pdr_stmt || ', CURSOR '||
                     ' ('||G_horiz_plan_stmt||' horiz '||
                     ' WHERE gpi.inventory_item_id = horiz.inventory_item_id '||
                       ' AND gpi.organization_id = horiz.organization_id ) horiz ';
         EXCEPTION
         when others then
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Error in horiz cursor stmt '||sqlerrm);
         END ;
      END IF;

      IF G_vert_pdr = 1 THEN
         BEGIN
            G_common_pdr_stmt := G_common_pdr_stmt || ', CURSOR '||
                     ' ('||G_vert_plan_stmt||' vert '||
                     ' WHERE gpi.inventory_item_id = vert.inventory_item_id '||
                       ' AND gpi.organization_id = vert.organization_id ) vert ';
         EXCEPTION
         when others then
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Error in vert cursor stmt '||sqlerrm);
         END ;
      END IF;

      IF G_excep_pdr = 1 THEN
         BEGIN
            G_common_pdr_stmt := G_common_pdr_stmt || ', CURSOR '||
                     ' ('||G_exc_plan_stmt||' exc '||
                     ' WHERE gpi.inventory_item_id = exc.inventory_item_id '||
                       ' AND gpi.organization_id = exc.organization_id ) exc ';
         EXCEPTION
         when others then
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Error in exc cursor stmt '||sqlerrm);
         END ;
      END IF;

      IF G_act_pdr = 1 THEN
         BEGIN
            G_common_pdr_stmt := G_common_pdr_stmt || ', CURSOR '||
                     ' ('||G_act_plan_stmt||' act '||
                     ' WHERE gpi.inventory_item_id = act.inventory_item_id '||
                       ' AND gpi.organization_id = act.organization_id ) act ';
         EXCEPTION
         when others then
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Error in act cursor stmt '||sqlerrm);
         END ;
      END IF;

      G_common_pdr_stmt := G_common_pdr_stmt || ' FROM gmp_pdr_items_gtmp gpi ';
      IF G_fsort IS NOT NULL THEN
         G_common_pdr_stmt := G_common_pdr_stmt || ' ORDER BY '||G_fsort;
      ELSE
         G_common_pdr_stmt := G_common_pdr_stmt || ' ORDER BY 1, 2 ) gpi ';
      END IF;

      IF G_ssort IS NOT NULL THEN
         G_common_pdr_stmt := G_common_pdr_stmt || ', '||G_ssort;
      END IF;

      IF G_tsort IS NOT NULL THEN
         G_common_pdr_stmt := G_common_pdr_stmt || ', '||G_tsort;
      END IF;

      IF G_fsort IS NOT NULL THEN
         G_common_pdr_stmt := G_common_pdr_stmt || ' ) gpi ';
      END IF;
      G_common_pdr_stmt := G_common_pdr_stmt || ' FROM DUAL ';

--      INSERT INTO ns_debug (LONGVAL) values (G_common_pdr_stmt);
      gmp_debug_message('G_common_pdr_stmt ' );

         DBMS_LOB.createtemporary(temp_clob, TRUE);
         DBMS_LOB.createtemporary(result, TRUE);

     -- generate XML data
         temp_clob := DBMS_XMLQUERY.getXML (G_common_pdr_stmt );  -- Bug: 9265463
         l_offset := DBMS_LOB.INSTR (lob_loc => temp_clob,
                                     pattern => '>',
                                     offset  => 1,
                                     nth     => 1);
        FND_FILE.PUT_LINE(FND_FILE.LOG,'l_offset  - '||l_offset);

    -- Remove the header
        DBMS_LOB.erase (temp_clob, l_offset,1);

    -- The following line of code ensures that XML data
    -- generated here uses the right encoding
        DBMS_LOB.writeappend (result, length(l_xml_header), l_xml_header);

    -- Append the rest to xml output
        DBMS_LOB.append (result, temp_clob);

    -- close context and free memory
     --   DBMS_XMLGEN.closeContext(qryctx);
        DBMS_LOB.FREETEMPORARY (temp_clob);
     -- B7481907 Rajesh Patangya Ends

      seq_stmt := 'select gmp_matl_rep_id_s.nextval from dual ';

      EXECUTE IMMEDIATE seq_stmt INTO x_seq_num ;
      INSERT INTO gmp_pdr_xml_temp(xml_file, file_type, pdr_xml_id) VALUES(result,1,x_seq_num );
      DBMS_LOB.FREETEMPORARY (result);
      ps_generate_output(x_seq_num,1);

   ELSE /* Not Combined PDR */

      IF G_horiz_pdr = 1 THEN /* Horizontal xml */

         G_horiz_pdr_stmt := NULL ;

         G_horiz_pdr_stmt := G_horiz_pdr_stmt || G_header_stmt ;

    -- Vpedarla bug: 8273098 modified the order of columns based on order by clause from parameters.
         G_horiz_pdr_stmt := G_horiz_pdr_stmt || ' , CURSOR ( SELECT gpi.organization_code organization_code, gpi.item_name item_name,  '||
            ' gpi.category_name category_name,  gpi.planner_code planner_code, gpi.buyer_name buyer_name, gpi.abc_class_name abc_class_name ';

         G_horiz_pdr_stmt := G_horiz_pdr_stmt || ', CURSOR '||
                     ' ('||G_horiz_plan_stmt||' horiz '||
                     ' WHERE gpi.inventory_item_id = horiz.inventory_item_id '||
                       ' AND gpi.organization_id = horiz.organization_id ) horiz ';

         G_horiz_pdr_stmt := G_horiz_pdr_stmt || ' FROM gmp_pdr_items_gtmp gpi ';

             -- Bug: 8486531
             IF (G_incl_items_no_activity = 2 )THEN
                G_horiz_pdr_stmt := G_horiz_pdr_stmt || ' , (select distinct inventory_item_id from gmp_horizontal_pdr_gtmp ) gtmp '||
                         ' where gpi.inventory_item_id = gtmp.inventory_item_id ';
             END IF;

         IF G_fsort IS NOT NULL THEN
            G_horiz_pdr_stmt := G_horiz_pdr_stmt || ' ORDER BY '||G_fsort;
         ELSE
            G_horiz_pdr_stmt := G_horiz_pdr_stmt || ' ORDER BY 1, 2 ) gpi ';
         END IF;

         IF G_ssort IS NOT NULL THEN
            G_horiz_pdr_stmt := G_horiz_pdr_stmt || ', '||G_ssort;
         END IF;

         IF G_tsort IS NOT NULL THEN
            G_horiz_pdr_stmt := G_horiz_pdr_stmt || ', '||G_tsort;
         END IF;

         IF G_fsort IS NOT NULL THEN
            G_horiz_pdr_stmt := G_horiz_pdr_stmt || ' ) gpi ';
         END IF;
         G_horiz_pdr_stmt := G_horiz_pdr_stmt || ' FROM DUAL ';

     -- B7481907 Rajesh Patangya starts
         DBMS_LOB.createtemporary(temp_clob, TRUE);
         DBMS_LOB.createtemporary(result, TRUE);

     -- generate XML data
         temp_clob := DBMS_XMLQUERY.getXML (G_horiz_pdr_stmt );  -- Bug: 9265463
         l_offset := DBMS_LOB.INSTR (lob_loc => temp_clob,
                                     pattern => '>',
                                     offset  => 1,
                                     nth     => 1);
         FND_FILE.PUT_LINE(FND_FILE.LOG,'l_offset  - '||l_offset);

    -- Remove the header
        DBMS_LOB.erase (temp_clob, l_offset,1);

    -- The following line of code ensures that XML data
    -- generated here uses the right encoding
        DBMS_LOB.writeappend (result, length(l_xml_header), l_xml_header);

    -- Append the rest to xml output
        DBMS_LOB.append (result, temp_clob);

    -- close context and free memory
     --   DBMS_XMLGEN.closeContext(qryctx);
        DBMS_LOB.FREETEMPORARY (temp_clob);
     -- B7481907 Rajesh Patangya Ends

         seq_stmt := 'select gmp_matl_rep_id_s.nextval from dual ';

         EXECUTE IMMEDIATE seq_stmt INTO x_seq_num ;
         INSERT INTO gmp_pdr_xml_temp(xml_file, file_type, pdr_xml_id) VALUES(result,2,x_seq_num );
        DBMS_LOB.FREETEMPORARY (result);
      	 ps_generate_output(x_seq_num,2);

--         INSERT INTO ns_debug (col3) values (G_horiz_pdr_stmt);

      END IF;

      IF G_vert_pdr = 1 THEN /* Vertical PDR */

         G_vert_pdr_stmt := NULL ;

         G_vert_pdr_stmt := G_vert_pdr_stmt || G_header_stmt ;

         G_vert_pdr_stmt := G_vert_pdr_stmt || ' , CURSOR ( SELECT gpi.item_name, gpi.organization_code, '||
            ' gpi.category_name, gpi.buyer_name, gpi.planner_code, gpi.abc_class_name ';

         G_vert_pdr_stmt := G_vert_pdr_stmt || ', CURSOR '||
                     ' ('||G_vert_plan_stmt||' vert '||
                     ' WHERE gpi.inventory_item_id = vert.inventory_item_id '||
                       ' AND gpi.organization_id = vert.organization_id ) vert ';

         G_vert_pdr_stmt := G_vert_pdr_stmt || ' FROM gmp_pdr_items_gtmp gpi ';
         IF G_fsort IS NOT NULL THEN
            G_vert_pdr_stmt := G_vert_pdr_stmt || ' ORDER BY '||G_fsort;
         ELSE
            G_vert_pdr_stmt := G_vert_pdr_stmt || ' ORDER BY 1, 2 ) gpi ';
         END IF;

         IF G_ssort IS NOT NULL THEN
            G_vert_pdr_stmt := G_vert_pdr_stmt || ', '||G_ssort;
         END IF;

         IF G_tsort IS NOT NULL THEN
            G_vert_pdr_stmt := G_vert_pdr_stmt || ', '||G_tsort;
         END IF;

         IF G_fsort IS NOT NULL THEN
            G_vert_pdr_stmt := G_vert_pdr_stmt || ' ) gpi ';
         END IF;
         G_vert_pdr_stmt := G_vert_pdr_stmt || ' FROM DUAL ';

     -- B7481907 Rajesh Patangya starts
         DBMS_LOB.createtemporary(temp_clob, TRUE);
         DBMS_LOB.createtemporary(result, TRUE);

     -- generate XML data
           temp_clob := DBMS_XMLQUERY.getXML (G_vert_pdr_stmt ); -- Bug: 9265463
         l_offset := DBMS_LOB.INSTR (lob_loc => temp_clob,
                                     pattern => '>',
                                     offset  => 1,
                                     nth     => 1);
         FND_FILE.PUT_LINE(FND_FILE.LOG,'l_offset  - '||l_offset);

    -- Remove the header
        DBMS_LOB.erase (temp_clob, l_offset,1);

    -- The following line of code ensures that XML data
    -- generated here uses the right encoding
        DBMS_LOB.writeappend (result, length(l_xml_header), l_xml_header);

    -- Append the rest to xml output
        DBMS_LOB.append (result, temp_clob);

    -- close context and free memory
     --   DBMS_XMLGEN.closeContext(qryctx);
        DBMS_LOB.FREETEMPORARY (temp_clob);
     -- B7481907 Rajesh Patangya Ends

         seq_stmt := 'select gmp_matl_rep_id_s.nextval from dual ';

         EXECUTE IMMEDIATE seq_stmt INTO x_seq_num ;
         INSERT INTO gmp_pdr_xml_temp(xml_file, file_type, pdr_xml_id) VALUES(result,3,x_seq_num );
         DBMS_LOB.FREETEMPORARY (result);
      	 ps_generate_output(x_seq_num,3);

--         INSERT INTO ns_debug (col3) values (G_vert_pdr_stmt);

      END IF;

      IF G_excep_pdr = 1 THEN

         G_excep_pdr_stmt := NULL ;

         G_excep_pdr_stmt := G_excep_pdr_stmt || G_header_stmt ;

         G_excep_pdr_stmt := G_excep_pdr_stmt || ' , CURSOR ( SELECT gpi.item_name, gpi.organization_code, '||
            ' gpi.category_name, gpi.buyer_name, gpi.planner_code, gpi.abc_class_name ';

         G_excep_pdr_stmt := G_excep_pdr_stmt || ', CURSOR '||
                     ' ('||G_exc_plan_stmt||' exc '||
                     ' WHERE gpi.inventory_item_id = exc.inventory_item_id '||
                       ' AND gpi.organization_id = exc.organization_id ) exc ';

         G_excep_pdr_stmt := G_excep_pdr_stmt || ' FROM gmp_pdr_items_gtmp gpi ';
         IF G_fsort IS NOT NULL THEN
            G_excep_pdr_stmt := G_excep_pdr_stmt || ' ORDER BY '||G_fsort;
         ELSE
            G_excep_pdr_stmt := G_excep_pdr_stmt || ' ORDER BY 1, 2 ) gpi ';
         END IF;

         IF G_ssort IS NOT NULL THEN
            G_excep_pdr_stmt := G_excep_pdr_stmt || ', '||G_ssort;
         END IF;

         IF G_tsort IS NOT NULL THEN
            G_excep_pdr_stmt := G_excep_pdr_stmt || ', '||G_tsort;
         END IF;

         IF G_fsort IS NOT NULL THEN
            G_excep_pdr_stmt := G_excep_pdr_stmt || ' ) gpi ';
         END IF;
         G_excep_pdr_stmt := G_excep_pdr_stmt || ' FROM DUAL ';

     -- B7481907 Rajesh Patangya starts
         DBMS_LOB.createtemporary(temp_clob, TRUE);
         DBMS_LOB.createtemporary(result, TRUE);

     -- generate XML data
         temp_clob := DBMS_XMLQUERY.getXML (G_excep_pdr_stmt ); -- Bug: 9265463
         l_offset := DBMS_LOB.INSTR (lob_loc => temp_clob,
                                     pattern => '>',
                                     offset  => 1,
                                     nth     => 1);
         FND_FILE.PUT_LINE(FND_FILE.LOG,'l_offset  - '||l_offset);

    -- Remove the header
        DBMS_LOB.erase (temp_clob, l_offset,1);

    -- The following line of code ensures that XML data
    -- generated here uses the right encoding
        DBMS_LOB.writeappend (result, length(l_xml_header), l_xml_header);

    -- Append the rest to xml output
        DBMS_LOB.append (result, temp_clob);

    -- close context and free memory
      --  DBMS_XMLGEN.closeContext(qryctx);
        DBMS_LOB.FREETEMPORARY (temp_clob);
     -- B7481907 Rajesh Patangya Ends

        seq_stmt := 'select gmp_matl_rep_id_s.nextval from dual ';

        EXECUTE IMMEDIATE seq_stmt INTO x_seq_num ;
        INSERT INTO gmp_pdr_xml_temp(xml_file, file_type, pdr_xml_id) VALUES(result,4,x_seq_num );
    --  INSERT INTO temp_r1(xml_file, file_type, pdr_xml_id) VALUES(result,4,x_seq_num );
         DBMS_LOB.FREETEMPORARY (result);
      	ps_generate_output(x_seq_num,4);

    --  INSERT INTO ns_debug (col3) values (G_excep_pdr_stmt);

      END IF;

      IF G_act_pdr = 1 THEN

         G_act_pdr_stmt := NULL ;

         G_act_pdr_stmt := G_act_pdr_stmt || G_header_stmt ;

         G_act_pdr_stmt := G_act_pdr_stmt || ' , CURSOR ( SELECT gpi.item_name, gpi.organization_code, '||
            ' gpi.category_name, gpi.buyer_name, gpi.planner_code, gpi.abc_class_name ';

         G_act_pdr_stmt := G_act_pdr_stmt || ', CURSOR '||
                     ' ('||G_act_plan_stmt||' act '||
                     ' WHERE gpi.inventory_item_id = act.inventory_item_id '||
                       ' AND gpi.organization_id = act.organization_id ) act ';

         G_act_pdr_stmt := G_act_pdr_stmt || ' FROM gmp_pdr_items_gtmp gpi ';
         IF G_fsort IS NOT NULL THEN
            G_act_pdr_stmt := G_act_pdr_stmt || ' ORDER BY '||G_fsort;
         ELSE
            G_act_pdr_stmt := G_act_pdr_stmt || ' ORDER BY 1, 2 ) gpi ';
         END IF;

         IF G_ssort IS NOT NULL THEN
            G_act_pdr_stmt := G_act_pdr_stmt || ', '||G_ssort;
         END IF;

         IF G_tsort IS NOT NULL THEN
            G_act_pdr_stmt := G_act_pdr_stmt || ', '||G_tsort;
         END IF;

         IF G_fsort IS NOT NULL THEN
            G_act_pdr_stmt := G_act_pdr_stmt || ' ) gpi ';
         END IF;
         G_act_pdr_stmt := G_act_pdr_stmt || ' FROM DUAL ';

     -- B7481907 Rajesh Patangya starts
         DBMS_LOB.createtemporary(temp_clob, TRUE);
         DBMS_LOB.createtemporary(result, TRUE);

     -- generate XML data
         temp_clob := DBMS_XMLQUERY.getXML (G_act_pdr_stmt ); -- Bug: 9265463
         l_offset := DBMS_LOB.INSTR (lob_loc => temp_clob,
                                     pattern => '>',
                                     offset  => 1,
                                     nth     => 1);
         FND_FILE.PUT_LINE(FND_FILE.LOG,'l_offset  - '||l_offset);

    -- Remove the header
        DBMS_LOB.erase (temp_clob, l_offset,1);

    -- The following line of code ensures that XML data
    -- generated here uses the right encoding
        DBMS_LOB.writeappend (result, length(l_xml_header), l_xml_header);

    -- Append the rest to xml output
        DBMS_LOB.append (result, temp_clob);

    -- close context and free memory
     --   DBMS_XMLGEN.closeContext(qryctx);
        DBMS_LOB.FREETEMPORARY (temp_clob);
     -- B7481907 Rajesh Patangya Ends

         seq_stmt := 'select gmp_matl_rep_id_s.nextval from dual ';

         EXECUTE IMMEDIATE seq_stmt INTO x_seq_num ;
         INSERT INTO gmp_pdr_xml_temp(xml_file, file_type, pdr_xml_id) VALUES(result,5,x_seq_num );
         DBMS_LOB.FREETEMPORARY (result);
      	 ps_generate_output(x_seq_num,5);

--         INSERT INTO ns_debug (col3) values (G_act_pdr_stmt);

      END IF;

   END IF; /* Combined PDR */

EXCEPTION
   WHEN OTHERS THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Error in procedure generate_xml '||sqlerrm);

END generate_xml;

FUNCTION plan_name RETURN VARCHAR2 IS
plan_name VARCHAR2(10);
BEGIN

   SELECT compile_designator
   INTO plan_name
   FROM msc_plans
   WHERE plan_id = G_plan_id;

   RETURN plan_name;

EXCEPTION WHEN OTHERS THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Error in function plan_name '||sqlerrm);
END plan_name;

FUNCTION plan_org ( org_id IN NUMBER) RETURN VARCHAR2 IS
org_code VARCHAR2(40);
BEGIN

   IF org_id = -999 THEN

      SELECT organization_code
      INTO org_code
      FROM gmp_plan_organization_v
      WHERE organization_id = org_id;

      RETURN org_code;

   END IF;

   SELECT organization_code
   INTO org_code
   FROM gmp_plan_organization_v
   WHERE organization_id = org_id
   AND plan_id = G_plan_id
   AND sr_instance_id = G_inst_id;

   RETURN org_code;

EXCEPTION WHEN OTHERS THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Error in function plan_org '||sqlerrm);
END plan_org;

FUNCTION category_set_name ( cat_set_id IN NUMBER) RETURN VARCHAR2 IS
cat_set_name VARCHAR2(35);
BEGIN

   SELECT category_set_name
   INTO cat_set_name
   FROM msc_category_sets
   WHERE category_set_id = cat_set_id
   AND sr_instance_id = G_inst_id;

   RETURN cat_set_name;

EXCEPTION WHEN OTHERS THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Error in function category_set_name '||sqlerrm);
END category_set_name;

FUNCTION lookup_meaning(l_lookup_type IN VARCHAR2,
                        l_lookup_code IN NUMBER) RETURN VARCHAR2 IS

meaning_text VARCHAR2(80);
BEGIN

   IF l_lookup_code IS NULL THEN
      RETURN NULL;
   END IF;

   SELECT meaning
   INTO meaning_text
   FROM fnd_lookup_values
   WHERE  language = userenv('LANG')
     AND lookup_type = l_lookup_type
     AND TO_NUMBER(lookup_code) = l_lookup_code;

   RETURN meaning_text;

EXCEPTION WHEN no_data_found THEN
    RETURN NULL;
END lookup_meaning;

/* ***************************************************************
* NAME
*	PROCEDURE - ps_generate_output
* PARAMETERS
* DESCRIPTION
*     Procedure used generate the final output.
* HISTORY
*     Namit   31Mar05 - Initial Version
*************************************************************** */

PROCEDURE ps_generate_output (
   p_sequence_num    IN    NUMBER,
   p_pdr_type        IN    NUMBER
)
IS

l_conc_id               NUMBER;
l_req_id                NUMBER;
l_phase			VARCHAR2(20);
l_status_code		VARCHAR2(20);
l_dev_phase		VARCHAR2(20);
l_dev_status		VARCHAR2(20);
l_message		VARCHAR2(20);
l_status		BOOLEAN;
l_log_text              VARCHAR2(200);


BEGIN

 gmp_debug_message(' ps_generate_output called with p_pdr_type '||p_pdr_type);

  l_conc_id := FND_REQUEST.SUBMIT_REQUEST('GMP','GMPPDROP','', '',FALSE,
        	    p_sequence_num,chr(0),'','','','','','','','','','','',
		    '','','','','','','','','','','','','','','',
		    '','','','','','','','','','',
		    '','','','','','','','','','',
		    '','','','','','','','','','',
		    '','','','','','','','','','',
		    '','','','','','','','','','',
		    '','','','','','','','','','',
		    '','','','','','','','','','');

   IF l_conc_id = 0 THEN
      l_log_text := FND_MESSAGE.GET;
      FND_FILE.PUT_LINE ( FND_FILE.LOG,l_log_text);
   ELSE
      COMMIT ;
   END IF;

--   FND_FILE.PUT_LINE ( FND_FILE.LOG, 'l_conc_id : '||to_char(l_conc_id));
   IF l_conc_id <> 0 THEN

      l_status := fnd_concurrent.WAIT_FOR_REQUEST
            (
                REQUEST_ID    =>  l_conc_id,
                INTERVAL      =>  30,
                MAX_WAIT      =>  900,
                PHASE         =>  l_phase,
                STATUS        =>  l_status_code,
                DEV_PHASE     =>  l_dev_phase,
                DEV_STATUS    =>  l_dev_status,
                MESSAGE       =>  l_message
            );

     gmp_debug_message(' Wait completed for conc request '||to_char(l_conc_id));


      DELETE FROM gmp_pdr_xml_temp WHERE pdr_xml_id = p_sequence_num;
    COMMIT;


--      FND_FILE.PUT_LINE ( FND_FILE.LOG, 'p_pdr_type = '||to_char(p_pdr_type));

      IF p_pdr_type = 1 THEN

     /* Bug: 6609251 Vpedarla added a NULL parameters for the submition of the FND request for XDOREPPB */
         l_req_id := FND_REQUEST.SUBMIT_REQUEST('XDO','XDOREPPB','', '',FALSE,'',
                l_conc_id,554,G_comb_pdr_temp,
             G_comb_pdr_locale,'Y','RTF','',scale_report,'','','','','',
             '','','','','','','','','','','','','','','',
             '','','','','','','','','','',
             '','','','','','','','','','',
             '','','','','','','','','','',
             '','','','','','','','','','',
             '','','','','','','','','','',
             '','','','','','','','','','',
             '','','','','','','','','','');
         gmp_debug_message( 'Submitted combined PDR with request id '||to_char(l_req_id));

      ELSIF p_pdr_type = 2 THEN

     /* Bug: 6609251 Vpedarla added a NULL parameters for the submition of the FND request for XDOREPPB */
         l_req_id := FND_REQUEST.SUBMIT_REQUEST('XDO','XDOREPPB','', '',FALSE,'',
                l_conc_id,554,G_horiz_pdr_temp,
             G_horiz_pdr_locale,'Y','RTF','',scale_report,'','','','','',
             '','','','','','','','','','','','','','','',
             '','','','','','','','','','',
             '','','','','','','','','','',
             '','','','','','','','','','',
             '','','','','','','','','','',
             '','','','','','','','','','',
             '','','','','','','','','','',
             '','','','','','','','','','');

        gmp_debug_message( 'Submitted Horizontal PDR with request id '||to_char(l_req_id));

      ELSIF p_pdr_type = 3 THEN

     /* Bug: 6609251 Vpedarla added a NULL parameters for the submition of the FND request for XDOREPPB */
         l_req_id := FND_REQUEST.SUBMIT_REQUEST('XDO','XDOREPPB','', '',FALSE,'',
                l_conc_id,554,G_vert_pdr_temp,
             G_vert_pdr_locale,'Y','RTF','',scale_report,'','','','','',
             '','','','','','','','','','','','','','','',
             '','','','','','','','','','',
             '','','','','','','','','','',
             '','','','','','','','','','',
             '','','','','','','','','','',
             '','','','','','','','','','',
             '','','','','','','','','','',
             '','','','','','','','','','');

        gmp_debug_message('Submitted Vertical PDR with request id '||to_char(l_req_id));

      ELSIF p_pdr_type = 4 THEN

     /* Bug: 6609251 Vpedarla added a NULL parameters for the submition of the FND request for XDOREPPB */
         l_req_id := FND_REQUEST.SUBMIT_REQUEST('XDO','XDOREPPB','', '',FALSE,'',
                l_conc_id,554,G_excep_pdr_temp,
             G_excep_pdr_locale,'N','RTF','',scale_report,'','','','','',
             '','','','','','','','','','','','','','','',
             '','','','','','','','','','',
             '','','','','','','','','','',
             '','','','','','','','','','',
             '','','','','','','','','','',
             '','','','','','','','','','',
             '','','','','','','','','','',
             '','','','','','','','','','');

      gmp_debug_message( 'Submitted Exception PDR with request id '||to_char(l_req_id));

      ELSIF p_pdr_type = 5 THEN

     /* Bug: 6609251 Vpedarla added a NULL parameters for the submition of the FND request for XDOREPPB */
         l_req_id := FND_REQUEST.SUBMIT_REQUEST('XDO','XDOREPPB','', '',FALSE,'',
                l_conc_id,554,G_act_pdr_temp,
             G_act_pdr_locale,'N','RTF','',scale_report,'','','','','',
             '','','','','','','','','','','','','','','',
             '','','','','','','','','','',
             '','','','','','','','','','',
             '','','','','','','','','','',
             '','','','','','','','','','',
             '','','','','','','','','','',
             '','','','','','','','','','',
             '','','','','','','','','','');

      gmp_debug_message( 'Submitted Action PDR with request id '||to_char(l_req_id));

      END IF;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
   FND_FILE.PUT_LINE ( FND_FILE.LOG, 'Exception in procedure ps_generate_output '||SQLERRM);
END ps_generate_output;

/* ***************************************************************
* NAME
*	PROCEDURE - xml_transfer
* PARAMETERS
* DESCRIPTION
*     Procedure used provide the XML as output of the concurrent program.
* HISTORY
*     Namit   31Mar05 - Initial Version
*************************************************************** */

PROCEDURE xml_transfer (
errbuf              OUT NOCOPY VARCHAR2,
retcode             OUT NOCOPY VARCHAR2,
p_sequence_num      IN         NUMBER
)IS

l_file CLOB;
file_varchar2 VARCHAR2(32767);
m_file CLOB;
l_len NUMBER;
l_limit NUMBER;

BEGIN

  gmp_debug_message(' xml_transfer started '|| to_char(sysdate, 'hh24:mi:ss'));

  file_varchar2 := NULL ;

   SELECT xml_file INTO l_file
   FROM gmp_pdr_xml_temp
   WHERE pdr_xml_id = p_sequence_num;
   l_limit:= 1;
   /* changed the Number from 10 to 15, becuase it is trimiing the First Standard Line */
   l_len := DBMS_LOB.GETLENGTH (l_file);
   gmp_debug_message('l_len :'||l_len );

   LOOP
     IF l_len > l_limit THEN
--BUG 6646373 DBMS_LOB.SUBSTR was failing for multi byte character as l_file being CLOB type variable.
--Introduced another clob variable m_file and after trimming it assigned to the varchar type variable.
--       file_varchar2 := DBMS_LOB.SUBSTR (l_file,10,l_limit);
           M_FILE := DBMS_LOB.SUBSTR (l_file,1024,l_limit);
	   -- Vpedarla 8605434
	  -- file_varchar2:=trim(M_FILE);
	    file_varchar2:=M_FILE;
         FND_FILE.PUT(FND_FILE.OUTPUT, file_varchar2);
         FND_FILE.PUT(FND_FILE.LOG,file_varchar2);
         If l_limit < 1026 THEN
            gmp_debug_message(' l_limit '||l_limit||'**' || file_varchar2 );
         END IF;
         file_varchar2 := NULL;
         m_file :=NULL;
         l_limit:= l_limit + 1024;
      ELSE
  --       file_varchar2 := DBMS_LOB.SUBSTR (l_file,10,l_limit);
           M_FILE := DBMS_LOB.SUBSTR (l_file,1024,l_limit);
	 -- Vpedarla 8605434
	 --  file_varchar2:=trim(M_FILE);
	  file_varchar2:=M_FILE;
         FND_FILE.PUT(FND_FILE.OUTPUT, file_varchar2);
         FND_FILE.PUT(FND_FILE.LOG,file_varchar2);
         file_varchar2 := NULL;
         m_file :=NULL;
         EXIT;
      END IF;
   END LOOP;
  gmp_debug_message(' xml_transfer end of loop '|| to_char(sysdate, 'hh24:mi:ss'));
EXCEPTION
   WHEN OTHERS THEN
   FND_FILE.PUT_LINE ( FND_FILE.LOG, 'Exception in procedure gmp_plng_dtl_report_pkg.xml_transfer '||SQLERRM);
END;

/*
REM+=========================================================================+
REM| FUNCTION NAME                                                           |
REM|    gmp_debug_message                                                    |
REM| DESCRIPTION                                                             |
REM|    This procedure is created to enable more debug messages              |
REM| HISTORY                                                                 |
REM|    Vpedarla Bug: 9366921 created this procedure                         |
REM+=========================================================================+
*/
PROCEDURE gmp_debug_message(pBUFF  IN  VARCHAR2) IS
BEGIN
   IF (l_debug = 'Y') then
        FND_FILE.PUT_LINE ( FND_FILE.LOG,pBUFF);
   END IF;
END gmp_debug_message;

END GMP_PLNG_DTL_REPORT_PKG;


/
