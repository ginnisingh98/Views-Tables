--------------------------------------------------------
--  DDL for Package Body FA_DEPRN_TAX_C_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_DEPRN_TAX_C_PKG" AS
/* $Header: facdptxb.pls 120.12.12010000.4 2009/10/15 11:46:24 pmadas ship $ */
g_print_debug boolean := fa_cache_pkg.fa_print_debug;

PROCEDURE fadptx_insert (
  errbuf         out nocopy varchar2,
  retcode        out nocopy number,
  argument1             in  varchar2,   -- book
  argument2             in  varchar2,   -- year
  argument3             in  varchar2,   -- locstruct_num
  argument4             in  varchar2,   -- start_state
  argument5             in  varchar2,   -- end_state
  argument6             in  varchar2,   -- cat_struct_num
  argument7             in  varchar2,   -- tax_asset_type_seg
  argument8             in  varchar2,   -- minor_cat_exist
  argument9             in  varchar2,   -- start_category
  argument10            in  varchar2,   -- end_category
  argument11            in  varchar2,   -- sale_code
  argument12            in  varchar2,   -- sum_rep
  argument13            in  varchar2,   -- all_rep
  argument14            in  varchar2,   -- add_rep
  argument15            in  varchar2,   -- dec_rep
  argument16            in  varchar2,   -- debug
  argument17            in  varchar2,   -- round --bug4919991
  argument18            in  varchar2,
  argument19            in  varchar2,
  argument20            in  varchar2,
  argument21            in  varchar2,
  argument22            in  varchar2,
  argument23            in  varchar2,
  argument24            in  varchar2,
  argument25            in  varchar2,
  argument26            in  varchar2,
  argument27            in  varchar2,
  argument28            in  varchar2,
  argument29            in  varchar2,
  argument30            in  varchar2,
  argument31            in  varchar2,
  argument32            in  varchar2,
  argument33            in  varchar2,
  argument34            in  varchar2,
  argument35            in  varchar2,
  argument36            in  varchar2,
  argument37            in  varchar2,
  argument38            in  varchar2,
  argument39            in  varchar2,
  argument40            in  varchar2,
  argument41            in  varchar2,
  argument42            in  varchar2,
  argument43            in  varchar2,
  argument44            in  varchar2,
  argument45            in  varchar2,
  argument46            in  varchar2,
  argument47            in  varchar2,
  argument48            in  varchar2,
  argument49            in  varchar2,
  argument50            in  varchar2,
  argument51            in  varchar2,
  argument52            in  varchar2,
  argument53            in  varchar2,
  argument54            in  varchar2,
  argument55            in  varchar2,
  argument56            in  varchar2,
  argument57            in  varchar2,
  argument58            in  varchar2,
  argument59            in  varchar2,
  argument60            in  varchar2,
  argument61            in  varchar2,
  argument62            in  varchar2,
  argument63            in  varchar2,
  argument64            in  varchar2,
  argument65            in  varchar2,
  argument66            in  varchar2,
  argument67            in  varchar2,
  argument68            in  varchar2,
  argument69            in  varchar2,
  argument70            in  varchar2,
  argument71            in  varchar2,
  argument72            in  varchar2,
  argument73            in  varchar2,
  argument74            in  varchar2,
  argument75            in  varchar2,
  argument76            in  varchar2,
  argument77            in  varchar2,
  argument78            in  varchar2,
  argument79            in  varchar2,
  argument80            in  varchar2,
  argument81            in  varchar2,
  argument82            in  varchar2,
  argument83            in  varchar2,
  argument84            in  varchar2,
  argument85            in  varchar2,
  argument86            in  varchar2,
  argument87            in  varchar2,
  argument88            in  varchar2,
  argument89            in  varchar2,
  argument90            in  varchar2,
  argument91            in  varchar2,
  argument92            in  varchar2,
  argument93            in  varchar2,
  argument94            in  varchar2,
  argument95            in  varchar2,
  argument96            in  varchar2,
  argument97            in  varchar2,
  argument98            in  varchar2,
  argument99            in  varchar2,
  argument100           in  varchar2) is

  h_request_id          NUMBER;
  h_login_id            NUMBER;
  h_err_msg             VARCHAR2(2000);
  h_debug               BOOLEAN;

  h_year                NUMBER;
  h_sum_rep             BOOLEAN; /*Print summary report */
  h_dec_rep             BOOLEAN; /*Print decrease report */
  h_round               BOOLEAN; --bug4919991


  h_req1                number;
  h_req2                number;
  h_req3                number;
  h_req4                number;

  -- bug#2448122:Obsolete all state parameter.
--  h_all_state         boolean; /*Select insert all state or one state */

  -- bug#2448122:Added the variables for parameters.
  h_book                VARCHAR2(30);
  h_locstruct_num       NUMBER;
  h_start_state         VARCHAR2(150);
  h_end_state           VARCHAR2(150);
  h_cat_struct_num      NUMBER;
  h_minor_cat_exist     VARCHAR2(1);
  h_start_category      VARCHAR2(150);
  h_end_category        VARCHAR2(150);
  h_sale_code           VARCHAR2(30);
  h_all_rep             VARCHAR2(3);
  h_add_rep             VARCHAR2(3);
  --
  -- Adding the changes made in version 120.12 to RER
  h_add_layout          BOOLEAN;
  l_iso_language        FND_LANGUAGES.iso_language%TYPE;
  l_iso_territory       FND_LANGUAGES.iso_territory%TYPE;


  /* Bug#3305764 - Enhancement to make category flexfield flexible */
  h_tax_asset_type_seg  VARCHAR2(30);

  NOSETUP_MINOR_CAT     Exception;

  -- Added error handlings on bug#2661575
  fadptx_insert_err     Exception;
  l_calling_fn          VARCHAR2(50) := 'fa_deprn_tax_c_pkg.fadptx_insert';

BEGIN

   h_debug := Upper(argument16) LIKE 'Y%';
   IF h_debug THEN
     fa_rx_util_pkg.enable_debug;
     if NOT fa_cache_pkg.fazcbc(X_book => argument1) then  -- Added for debug standard
        raise fadptx_insert_err;
     end if;
   END IF;

   IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('fadptx_insert: ' || 'argument1:' ||argument1);
        fa_rx_util_pkg.debug('fadptx_insert: ' || 'argument2:' ||argument2);
        fa_rx_util_pkg.debug('fadptx_insert: ' || 'argument3:' ||argument3);
        fa_rx_util_pkg.debug('fadptx_insert: ' || 'argument4:' ||argument4);
        fa_rx_util_pkg.debug('fadptx_insert: ' || 'argument5:' ||argument5);
        fa_rx_util_pkg.debug('fadptx_insert: ' || 'argument6:' ||argument6);
        fa_rx_util_pkg.debug('fadptx_insert: ' || 'argument7:' ||argument7);
        fa_rx_util_pkg.debug('fadptx_insert: ' || 'argument8:' ||argument8);
        fa_rx_util_pkg.debug('fadptx_insert: ' || 'argument9:' ||argument9);
        fa_rx_util_pkg.debug('fadptx_insert: ' || 'argument10:' ||argument10);
        fa_rx_util_pkg.debug('fadptx_insert: ' || 'argument11:' ||argument11);
        fa_rx_util_pkg.debug('fadptx_insert: ' || 'argument12:' ||argument12);
        fa_rx_util_pkg.debug('fadptx_insert: ' || 'argument13:' ||argument13);
        fa_rx_util_pkg.debug('fadptx_insert: ' || 'argument14:' ||argument14);
        fa_rx_util_pkg.debug('fadptx_insert: ' || 'argument15:' ||argument15);
        fa_rx_util_pkg.debug('fadptx_insert: ' || 'argument16:' ||argument16);
        fa_rx_util_pkg.debug('fadptx_insert: ' || 'argument17:' ||argument17);
   END IF;

   -- bug#2448122:Set variables from parameters
   h_book := argument1;
   h_locstruct_num := To_number(argument3);
   h_start_state := argument4;
   h_end_state := argument5;
   h_cat_struct_num:= To_number(argument6);
   h_minor_cat_exist := argument8;
   h_start_category := argument9;
   h_end_category := argument10;
   h_sale_code := argument11;
   h_all_rep := argument13;
   h_add_rep := argument14;

--   if argument6 is null then
--   if h_minor_cat_exist is null then

   if h_start_category is null or h_end_category is null then /* bug3305784 */

        RAISE NOSETUP_MINOR_CAT;

   end if;

/* Bug#3305764 - Enhancement to make Category Flexfield flexible */
   if argument7 is null then
     h_tax_asset_type_seg := 'MINOR_CATEGORY';
   else
     h_tax_asset_type_seg := argument7;
   end if;

   h_request_id := fnd_global.conc_request_id;
--   fnd_profile.get('LOGIN_ID',h_login_id);
   fnd_profile.get('USER_ID',h_login_id);  -- bug#2661575

   h_year := to_number(argument2);

   h_sum_rep := Upper(argument12) LIKE 'Y%';
   h_dec_rep := Upper(argument15) LIKE 'Y%';

   h_round   := Upper(argument17) LIKE 'Y%'; --bug4919991

   -- bug#2448122 Obsolete all state
--   h_all_state := Upper(argument14) LIKE 'Y%';

   fa_deprn_tax_rep_pkg.fadptx_insert(
        errbuf          => errbuf,
        retcode         => retcode,
        book            => h_book,
        year            => h_year,
        state_from      => h_start_state,
        state_to        => h_end_state,
        tax_asset_type_seg => h_tax_asset_type_seg,  -- Bug#3305764 - Enhancement to make Category Flexfield flexible
        category_from   => h_start_category,
        category_to     => h_end_category,
        sale_code       => h_sale_code,
        all_state       => null,
        rounding        => h_round, --bug4919991
        request_id      => h_request_id,
        login_id        => h_login_id
                                         );
   if retcode =2 then
     raise fadptx_insert_err;
   else
     commit;
   end if;

/*==============================================================================
Run reports
FADTXS.rdf (Depreciable Asset Tax Report)
FADTXA.rdf (Detail Report by Asset Type (All/Addition) 180char) --All Assets
FADTXA.rdf (Detail Report by Asset Type (All/Addition) 180char) --Asset Addition
FADTXD.rdf (Detail Report by Asset Type (Decrease)

If these parameters are TRUE, reports are printed.
If FALSE, not printed.
==============================================================================*/

  -- Adding the changes made in version 120.12 to RER
  SELECT lower(iso_language),iso_territory
    INTO l_iso_language,l_iso_territory
    FROM FND_LANGUAGES
   WHERE language_code = USERENV('LANG');

if h_sum_rep then
         -- Adding the changes made in version 120.12 to RER
        h_add_layout:=  fnd_request.add_layout(
                        template_appl_name  => 'OFA',
                        template_code       => 'FADTXS',
                        template_language   => l_iso_language,
                        template_territory  => l_iso_territory,
                        output_format       => 'PDF'
                            );

        -- Bug 8985010: Passing the values for the new parameters added
        h_req1 := FND_REQUEST.SUBMIT_REQUEST('OFA','FADTXS',null,sysdate,FALSE,
                h_request_id,h_book,h_year,h_locstruct_num,null,
                h_cat_struct_num, h_tax_asset_type_seg, h_minor_cat_exist,
                h_start_category, h_end_category, chr(0));
        -- End Bug 8985010

        if h_req1 = 0 then

                FND_MESSAGE.SET_NAME('OFA','FA_DEPRN_TAX_ERROR');
                FND_MESSAGE.SET_TOKEN('REQUEST_ID',h_req1,TRUE);
                FND_FILE.PUT_LINE(fnd_file.output,fnd_message.get);

        else
                FND_MESSAGE.SET_NAME('OFA','FA_DEPRN_TAX_COMP');
                FND_MESSAGE.SET_TOKEN('REQUEST_ID',h_req1,TRUE);
                FND_FILE.PUT_LINE(fnd_file.output,fnd_message.get);

        end if;

end if;

if h_all_rep='132' or h_all_rep='180'  then
         -- Adding the changes made in version 120.12 to RER
        h_add_layout:=  fnd_request.add_layout(
                        template_appl_name  => 'OFA',
                        template_code       => 'FADTXA'||h_all_rep,
                        template_language   => l_iso_language,
                        template_territory  => l_iso_territory,
                        output_format       => 'PDF'
                            );

        h_req2 :=FND_REQUEST.SUBMIT_REQUEST('OFA','FADTXA'||h_all_rep,null,sysdate,FALSE,
                h_request_id,h_book,h_year,h_locstruct_num,null,'ALL','AUTO',h_all_rep,chr(0));

        if h_req2 = 0 then

                FND_MESSAGE.SET_NAME('OFA','FA_DEPRN_TAX_ERROR');
                FND_MESSAGE.SET_TOKEN('REQUEST_ID',h_req2,TRUE);
                FND_FILE.PUT_LINE(fnd_file.output,fnd_message.get);

        else
                FND_MESSAGE.SET_NAME('OFA','FA_DEPRN_TAX_COMP');
                FND_MESSAGE.SET_TOKEN('REQUEST_ID',h_req2,TRUE);
                FND_FILE.PUT_LINE(fnd_file.output,fnd_message.get);

        end if;

end if;

if h_add_rep='132' or h_add_rep='180' then
         -- Adding the changes made in version 120.12 to RER
        h_add_layout:=  fnd_request.add_layout(
                        template_appl_name  => 'OFA',
                        template_code       => 'FADTXA'||h_add_rep,
                        template_language   => l_iso_language,
                        template_territory  => l_iso_territory,
                        output_format       => 'PDF'
                            );

        h_req3 :=FND_REQUEST.SUBMIT_REQUEST('OFA','FADTXA'||h_add_rep,null,sysdate,FALSE,
                h_request_id,h_book,h_year,h_locstruct_num,null,'ADDITION','NOT APPLICABLE',h_add_rep,chr(0));

        if h_req3 = 0 then

                FND_MESSAGE.SET_NAME('OFA','FA_DEPRN_TAX_ERROR');
                FND_MESSAGE.SET_TOKEN('REQUEST_ID',h_req3,TRUE);
                FND_FILE.PUT_LINE(fnd_file.output,fnd_message.get);

        else
                FND_MESSAGE.SET_NAME('OFA','FA_DEPRN_TAX_COMP');
                FND_MESSAGE.SET_TOKEN('REQUEST_ID',h_req3,TRUE);
                FND_FILE.PUT_LINE(fnd_file.output,fnd_message.get);

        end if;

end if;

if h_dec_rep then
         -- Adding the changes made in version 120.12 to RER
        h_add_layout:=  fnd_request.add_layout(
                        template_appl_name  => 'OFA',
                        template_code       => 'FADTXD',
                        template_language   => l_iso_language,
                        template_territory  => l_iso_territory,
                        output_format       => 'PDF'
                            );

        h_req4 :=FND_REQUEST.SUBMIT_REQUEST('OFA','FADTXD',null,sysdate,FALSE,
                h_request_id,h_book,h_year,h_locstruct_num,null,chr(0));

        if h_req4 = 0 then

                FND_MESSAGE.SET_NAME('OFA','FA_DEPRN_TAX_ERROR');
                FND_MESSAGE.SET_TOKEN('REQUEST_ID',h_req4,TRUE);
                FND_FILE.PUT_LINE(fnd_file.output,fnd_message.get);

        else
                FND_MESSAGE.SET_NAME('OFA','FA_DEPRN_TAX_COMP');
                FND_MESSAGE.SET_TOKEN('REQUEST_ID',h_req4,TRUE);
                FND_FILE.PUT_LINE(fnd_file.output,fnd_message.get);

        end if;

end if;

Exception
   When NOSETUP_MINOR_CAT then
        FND_MESSAGE.SET_NAME('OFA','FA_DEPRN_TAX_NOSETUP_MINOR_CAT');
        FND_FILE.PUT_LINE(fnd_file.log,fnd_message.get);

        retcode :=2;
        errbuf := sqlerrm;

  When  fadptx_insert_err THEN
        fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn);
        retcode :=2;
        errbuf := sqlerrm;

  When OTHERS THEN
        fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn);
        retcode :=2;
        errbuf := sqlerrm;

END fadptx_insert;

END FA_DEPRN_TAX_C_PKG;

/
