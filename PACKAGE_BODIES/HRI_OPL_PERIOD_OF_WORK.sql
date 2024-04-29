--------------------------------------------------------
--  DDL for Package Body HRI_OPL_PERIOD_OF_WORK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OPL_PERIOD_OF_WORK" AS
/* $Header: hriopow.pkb 120.2 2005/06/21 22:23:44 anmajumd noship $ */
--
-- Global variables
--
-- Record Type for populating table hri_cs_pow_band_ct
--
TYPE g_pow_band_record IS RECORD
 (set_bucket_id          NUMBER
 ,set_bucket_custom_id   NUMBER
 ,set_short_name         VARCHAR2(30)
 ,set_uom                VARCHAR2(10)
 ,band_sequence          NUMBER
 ,band_range_low         NUMBER
 ,band_range_high        NUMBER
 ,wkth_wktyp_sk_fk       VARCHAR2(240)
 );
 --
 -- Table type for populating the table hri_cs_pow_band_ct
 --
 TYPE g_pow_band_tab_type IS TABLE OF g_pow_band_record INDEX BY BINARY_INTEGER;
 --
 -- Record type to hold pow cursor values
 --
 TYPE g_pow_bucket_record IS RECORD
 (bucket_id          NUMBER
 ,bucket_custom_id   NUMBER
 ,short_name         VARCHAR2(30)
 ,range1_low         NUMBER
 ,range1_high        NUMBER
 ,range2_low         NUMBER
 ,range2_high        NUMBER
 ,range3_low         NUMBER
 ,range3_high        NUMBER
 ,range4_low         NUMBER
 ,range4_high        NUMBER
 ,range5_low         NUMBER
 ,range5_high        NUMBER
 ,range6_low         NUMBER
 ,range6_high        NUMBER
 ,range7_low         NUMBER
 ,range7_high        NUMBER
 ,range8_low         NUMBER
 ,range8_high        NUMBER
 ,range9_low         NUMBER
 ,range9_high        NUMBER
 ,range10_low        NUMBER
 ,range10_high       NUMBER
 ,uom                VARCHAR2(10)
 ,wkth_wktyp_sk_fk   VARCHAR2(30)
);
--
g_counter NUMBER := 0;
--
-- -----------------------------------------------------------------------------
-- Inserts row into concurrent program log
-- -----------------------------------------------------------------------------
--
PROCEDURE output(p_text  VARCHAR2) IS

BEGIN
  --
  HRI_BPL_CONC_LOG.output(p_text);
  --
END output;

-- -----------------------------------------------------------------------------
-- Inserts row into concurrent program log if debugging is enabled
-- -----------------------------------------------------------------------------
--
PROCEDURE dbg(p_text  VARCHAR2) IS

BEGIN
  --
  HRI_BPL_CONC_LOG.dbg(p_text);
  --
END dbg;

--
-- ------------------------------------------------------------------------------
-- Checks if records are defined in the buckets and populates the record in
-- the table type
-- ------------------------------------------------------------------------------
--
PROCEDURE chk_and_populate_pow_records(p_pow_bucket_record   IN g_pow_bucket_record
                                       ,p_band_sequence      IN NUMBER
                                       ,p_range_low          IN NUMBER
                                       ,p_range_high         IN NUMBER
                                       ,p_populate_flag      IN OUT NOCOPY VARCHAR2
                                       ,p_pow_band_tab_type  IN OUT NOCOPY g_pow_band_tab_type) IS

--
BEGIN
  --
  -- Flag when both low and high values are null
  --
  IF (p_range_low IS NULL) AND (p_range_high IS NULL)  THEN
    --
    -- If the final value for the highest band is not null then make it null
    -- This is done to ensure every record falls into a pow band
    -- Set the warning flag
    --
    IF (p_pow_band_tab_type(g_counter).band_range_high IS NOT NULL) THEN
      --
      p_pow_band_tab_type(g_counter).band_range_high := NULL;
      --
      g_warning_flag  := 'Y';
      --
      output('The high value for band' || to_char(g_counter) ||  ' of bucket ' || p_pow_band_tab_type(g_counter).set_short_name || ' is being set to');
      output('null. This is done to ensure that all the records are inside a period of ');
      output('work band.');
      --
      p_populate_flag := 'N';
      --
    END IF;
  --
  -- Populate only when values are present in the buckets
  --
  ELSIF (p_range_low IS NOT NULL OR p_range_high IS NOT NULL) THEN
    --
    g_counter := g_counter + 1;
    --
    p_pow_band_tab_type(g_counter).set_bucket_id        := p_pow_bucket_record.bucket_id;
    p_pow_band_tab_type(g_counter).set_bucket_custom_id := p_pow_bucket_record.bucket_custom_id;
    p_pow_band_tab_type(g_counter).set_short_name       := p_pow_bucket_record.short_name;
    p_pow_band_tab_type(g_counter).set_uom              := p_pow_bucket_record.uom;
    p_pow_band_tab_type(g_counter).band_sequence        := p_band_sequence;
    p_pow_band_tab_type(g_counter).band_range_low       := p_range_low;
    p_pow_band_tab_type(g_counter).band_range_high      := p_range_high;
    p_pow_band_tab_type(g_counter).wkth_wktyp_sk_fk     := p_pow_bucket_record.wkth_wktyp_sk_fk;
    --
    -- Flag whenever high value is set to NULL
    --
    IF p_range_high IS NULL THEN
      --
      p_populate_flag := 'N';
      --
    END IF;
    --
  END IF;
  --
END chk_and_populate_pow_records;
--
-- ------------------------------------------------------------------------------
-- Collects the records in a table type
-- ------------------------------------------------------------------------------
--
PROCEDURE collect_records(p_pow_band_tab_type OUT NOCOPY g_pow_band_tab_type) IS
  --
  l_pow_bucket_record      g_pow_bucket_record;
  l_band_sequence          NUMBER;
  l_populate_flag          VARCHAR2(1) := 'Y';
  l_range_low              VARCHAR2(100);
  l_range_high             VARCHAR2(100);
  --
  CURSOR pow_csr IS
  SELECT
   bkt.bucket_id          bucket_id
  ,bbc.id                 bucket_custom_id
  ,bkt.short_name         short_name
  ,bbc.range1_low         range1_low
  ,bbc.range1_high        range1_high
  ,bbc.range2_low         range2_low
  ,bbc.range2_high        range2_high
  ,bbc.range3_low         range3_low
  ,bbc.range3_high        range3_high
  ,bbc.range4_low         range4_low
  ,bbc.range4_high        range4_high
  ,bbc.range5_low         range5_low
  ,bbc.range5_high        range5_high
  ,bbc.range6_low         range6_low
  ,bbc.range6_high        range6_high
  ,bbc.range7_low         range7_low
  ,bbc.range7_high        range7_high
  ,bbc.range8_low         range8_low
  ,bbc.range8_high        range8_high
  ,bbc.range9_low         range9_low
  ,bbc.range9_high        range9_high
  ,bbc.range10_low        range10_low
  ,bbc.range10_high       range10_high
  ,bkt.uom                uom
  ,CASE
     WHEN bkt.short_name = 'HRI_DBI_LOW_BAND_CURRENT' THEN
       'EMP'
     WHEN bkt.short_name = 'HRI_DBI_POW_PLCMNT_BAND' THEN
       'CWK'
     ELSE
       NULL
   END                    wkth_wktyp_sk_fk
  FROM bis_bucket bkt,
       bis_bucket_customizations bbc
  WHERE bkt.bucket_id = bbc.bucket_id
  AND bkt.short_name IN ('HRI_DBI_LOW_BAND_CURRENT','HRI_DBI_POW_PLCMNT_BAND');

BEGIN
  --
  OPEN pow_csr;
    --
    LOOP
      --
      FETCH pow_csr INTO l_pow_bucket_record;
      EXIT WHEN pow_csr%NOTFOUND;
      --
      -- Loop for 10 times (since there are 10 buckets in  bis_bucket table)
      --
      FOR n IN 1..10 LOOP
        --
        -- Check if the table needs to be populated
        --
        IF (l_populate_flag = 'N') THEN
          --
          -- Set the populate flag to 'Y' for next iteration and then exit the
          -- current loop
          --
          l_populate_flag := 'Y';
          --
          EXIT;
          --
        ELSIF (n = 1) THEN
          --
          l_band_sequence := 1;
          l_range_low  := l_pow_bucket_record.range1_low;
          l_range_high := l_pow_bucket_record.range1_high;
          --
        ELSIF (n = 2) THEN
          --
          l_band_sequence := 2;
          l_range_low  := l_pow_bucket_record.range2_low;
          l_range_high := l_pow_bucket_record.range2_high;
          --
        ELSIF (n = 3) THEN
          --
          l_band_sequence := 3;
          l_range_low  := l_pow_bucket_record.range3_low;
          l_range_high := l_pow_bucket_record.range3_high;
          --
        ELSIF (n = 4) THEN
          --
          l_band_sequence := 4;
          l_range_low  := l_pow_bucket_record.range4_low;
          l_range_high := l_pow_bucket_record.range4_high;
          --
        ELSIF (n = 5) THEN
          --
          l_band_sequence := 5;
          l_range_low  := l_pow_bucket_record.range5_low;
          l_range_high := l_pow_bucket_record.range5_high;
          --
        ELSIF (n = 6) THEN
          --
          l_band_sequence := 6;
          l_range_low  := l_pow_bucket_record.range6_low;
          l_range_high := l_pow_bucket_record.range6_high;
          --
        ELSIF (n = 7) THEN
          --
          l_band_sequence := 7;
          l_range_low  := l_pow_bucket_record.range7_low;
          l_range_high := l_pow_bucket_record.range7_high;
          --
        ELSIF (n = 8) THEN
          --
          l_band_sequence := 8;
          l_range_low  := l_pow_bucket_record.range8_low;
          l_range_high := l_pow_bucket_record.range8_high;
          --
        ELSIF (n = 9) THEN
          --
          l_band_sequence := 9;
          l_range_low  := l_pow_bucket_record.range9_low;
          l_range_high := l_pow_bucket_record.range9_high;
          --
        ELSE
          --
          l_band_sequence := 10;
          l_range_low  := l_pow_bucket_record.range10_low;
          l_range_high := l_pow_bucket_record.range10_high;
          --
        END IF;
        --
        chk_and_populate_pow_records(l_pow_bucket_record
                                     ,l_band_sequence
                                     ,l_range_low
                                     ,l_range_high
                                     ,l_populate_flag
                                     ,p_pow_band_tab_type
                                    );
      --
      END LOOP;
    --
    END LOOP;
    --
END collect_records;

--
-- ----------------------------------------------------------------------------
-- Inserts the records in table hri_cs_pow_band_ct
-- ----------------------------------------------------------------------------
--
PROCEDURE insert_records(p_pow_band_tab_type IN g_pow_band_tab_type) IS
  --
  l_current_time           DATE   := SYSDATE;
  l_user_id                NUMBER := fnd_global.user_id;
  --
BEGIN
  --
  FOR i in p_pow_band_tab_type.FIRST..p_pow_band_tab_type.LAST LOOP
  --
    INSERT INTO HRI_CS_POW_BAND_CT
      (
       pow_band_sk_pk
      ,set_bucket_id
      ,set_bucket_custom_id
      ,set_short_name
      ,set_uom
      ,band_sequence
      ,band_range_low
      ,band_range_high
      ,wkth_wktyp_sk_fk
      ,created_by
      ,creation_date
      ,last_update_date
      ,last_updated_by
      ,last_update_login
     )
    VALUES
     (hri_cs_pow_band_ct_s.nextval
     ,p_pow_band_tab_type(i).set_bucket_id
     ,p_pow_band_tab_type(i).set_bucket_custom_id
     ,p_pow_band_tab_type(i).set_short_name
     ,p_pow_band_tab_type(i).set_uom
     ,p_pow_band_tab_type(i).band_sequence
     ,p_pow_band_tab_type(i).band_range_low
     ,p_pow_band_tab_type(i).band_range_high
     ,p_pow_band_tab_type(i).wkth_wktyp_sk_fk
     ,l_user_id
     ,l_current_time
     ,l_current_time
     ,l_user_id
     ,l_user_id
     );
  --
  END LOOP;
  --
 END insert_records;
 --
 -- ------------------------------------------------------------------------------
 -- Full refresh entry point
 -- ------------------------------------------------------------------------------
 --
 PROCEDURE full_refresh IS
   --
   l_pow_band_tab_type      g_pow_band_tab_type;
   l_hri_schema             VARCHAR2(300);
   l_dummy1                 VARCHAR2(2000);
   l_dummy2                 VARCHAR2(2000);
   --
 BEGIN
   --
   --
   -- Truncate the table hri_cs_pow_band_ct
   --
   IF (fnd_installation.get_app_info('HRI',l_dummy1, l_dummy2, l_hri_schema)) THEN
     --
     EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || l_hri_schema || '.HRI_CS_POW_BAND_CT';
     --
   END IF;
   --

   collect_records(l_pow_band_tab_type);
   --
   insert_records(l_pow_band_tab_type);
   --
   -- Commit changes
   --
   COMMIT;
   --
 END full_refresh;

--
END HRI_OPL_PERIOD_OF_WORK;

/
