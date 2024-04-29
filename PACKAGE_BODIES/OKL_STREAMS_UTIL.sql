--------------------------------------------------------
--  DDL for Package Body OKL_STREAMS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_STREAMS_UTIL" AS
/* $Header: OKLRSULB.pls 120.20.12010000.10 2009/11/03 08:36:36 rgooty ship $ */

  PROCEDURE LOG_MESSAGE(p_msgs_tbl            IN  log_msg_tbl,
                        p_translate           IN  VARCHAR2 DEFAULT G_TRUE,
                        p_file_name           IN  VARCHAR2,
			x_return_status       OUT NOCOPY VARCHAR2)
  IS

   CURSOR okl_csr_fnd_msg(p_name IN VARCHAR2)
   IS
   SELECT MESSAGE_TEXT
   FROM FND_NEW_MESSAGES
   WHERE LANGUAGE_CODE = 'US'
   AND MESSAGE_NAME LIKE p_name;

   uFile_type              FILE_TYPE;

  BEGIN
       x_return_status := G_RET_STS_SUCCESS;
        uFile_type := utl_file.fopen(Fnd_Profile.VALUE(G_LOG_DIR),p_file_name,'A');

	FOR i IN 1..p_msgs_tbl.COUNT
	LOOP

	  IF Fnd_Api.TO_BOOLEAN(p_translate)
	  THEN
	    FOR l_okl_csr_fnd_msg IN okl_csr_fnd_msg(p_msgs_tbl(i))
		LOOP
          utl_file.put_line(uFile_type,l_okl_csr_fnd_msg.message_text);
        END LOOP;
      ELSE
        utl_file.put_line(uFile_type,p_msgs_tbl(i));
      END IF;

	END LOOP;

      utl_file.fclose(uFile_type);

  EXCEPTION
     WHEN utl_file.write_error THEN
       IF (utl_file.is_open(uFile_type)) THEN
         utl_file.fclose(uFile_type);
       END IF;

     WHEN utl_file.invalid_path THEN
       x_return_status := G_RET_STS_ERROR;

     WHEN utl_file.invalid_operation THEN
       x_return_status := G_RET_STS_ERROR;
       IF (utl_file.is_open(uFile_type)) THEN
         utl_file.fclose(uFile_type);
       END IF;
     WHEN OTHERS THEN
       x_return_status := G_RET_STS_UNEXP_ERROR;
       IF (utl_file.is_open(uFile_type)) THEN
         utl_file.fclose(uFile_type);
       END IF;

  END LOG_MESSAGE;

  PROCEDURE LOG_MESSAGE(p_msg_name            IN     VARCHAR2,
                        p_translate           IN  VARCHAR2 DEFAULT G_TRUE ,
                        p_file_name            IN     VARCHAR2,
			x_return_status 	   OUT NOCOPY VARCHAR2)
  IS

   CURSOR okl_csr_fnd_msg(p_name IN VARCHAR2)
   IS
   SELECT MESSAGE_TEXT
   FROM FND_NEW_MESSAGES
   WHERE LANGUAGE_CODE = 'US'
   AND MESSAGE_NAME LIKE p_name;

   uFile_type              FILE_TYPE;

  BEGIN
       x_return_status := G_RET_STS_SUCCESS;
        uFile_type := utl_file.fopen(Fnd_Profile.VALUE(G_LOG_DIR),p_file_name,'A');

	IF Fnd_Api.TO_BOOLEAN(p_translate)
	THEN
	  FOR l_okl_csr_fnd_msg IN okl_csr_fnd_msg(p_msg_name)
      LOOP
        utl_file.put_line(uFile_type,l_okl_csr_fnd_msg.message_text);
      END LOOP;
    ELSE
      utl_file.put_line(uFile_type,p_msg_name);
    END IF;

     utl_file.fclose(uFile_type);

  EXCEPTION
     WHEN utl_file.write_error THEN
       x_return_status := G_RET_STS_ERROR;
       IF (utl_file.is_open(uFile_type)) THEN
         utl_file.fclose(uFile_type);
       END IF;

     WHEN utl_file.invalid_path THEN
       x_return_status := G_RET_STS_ERROR;

     WHEN utl_file.invalid_operation THEN
       x_return_status := G_RET_STS_ERROR;
       IF (utl_file.is_open(uFile_type)) THEN
         utl_file.fclose(uFile_type);
       END IF;
     WHEN OTHERS THEN
       x_return_status := G_RET_STS_UNEXP_ERROR;
       -- store SQL error message on message stack for caller
       Okl_Api.SET_MESSAGE(p_app_name    => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => SQLCODE,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => SQLERRM );
       IF (utl_file.is_open(uFile_type)) THEN
         utl_file.fclose(uFile_type);
       END IF;

  END LOG_MESSAGE;

  PROCEDURE LOG_MESSAGE(p_msg_count            IN     NUMBER,
                        p_file_name            IN     VARCHAR2,
			x_return_status        OUT NOCOPY VARCHAR2
                       )
  IS
   l_error_msg VARCHAR2(4000) := '';
   l_msg_text VARCHAR2(2000);
   l_msg_count NUMBER;
  l_new_line        VARCHAR2(10) := Fnd_Global.NEWLINE;
  BEGIN
       x_return_status := G_RET_STS_SUCCESS;

     -- GET THE MESSAGES FROM FND_MESSAGES
     FOR i IN 1..p_msg_count
     LOOP
         Fnd_Msg_Pub.get(p_data => l_msg_text,
                         p_msg_index_out => l_msg_count,
                         p_encoded => G_FALSE,
                         p_msg_index => Fnd_Msg_Pub.g_next);
     	 IF i = 1 THEN
	       l_error_msg := l_msg_text;
     	 ELSE
	       l_error_msg := l_error_msg || l_new_line || l_msg_text;
    	 END IF;
      END LOOP;

      LOG_MESSAGE(p_msg_name            => l_error_msg,
                  p_translate            => G_FALSE,
                  p_file_name            => p_file_name,
	          x_return_status 	 => x_return_status
                 );


  EXCEPTION
     WHEN OTHERS THEN
       x_return_status := G_RET_STS_UNEXP_ERROR;
  END LOG_MESSAGE;

  PROCEDURE GET_FND_PROFILE_VALUE(p_name IN VARCHAR2,
                                  x_value OUT NOCOPY VARCHAR2)
  IS
  BEGIN
    x_value := Fnd_Profile.VALUE(p_name);
  EXCEPTION
     WHEN OTHERS THEN
       x_value := p_name;
  END;
-- BAKUCHIB Bug 2835092 start
--------------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : round_streams_amount
-- Description          : Returns PL/SQL table of record rounded amounts
--                        of OKL_STRM_ELEMENTS type
-- Business Rules       : We sum the amounts given as I/P PL/SQL table first.
--                        And then we round the amounts using existing
--                        rounding rule and then sum them these up.
--                        If we find a difference between rounded amount
--                        and non-rounded amount then based on already existing
--                        rule we do adjustment to the first amount or
--                        last amount or the High value amount of the PL/SQL
--                        table of records.We then give the rounded values
--                        thru O/P PL/SQL table of records.
-- Parameters           : P_chr_id,
--                        p_selv_tbl of OKL_STRM_ELEMENTS type
--                        x_selv_tbl of OKL_STRM_ELEMENTS type
-- Version              : 1.0
-- History              : BAKUCHIB  31-JUL-2003 - 2835092 created
-- End of Commnets
--------------------------------------------------------------------------------
FUNCTION Round_Streams_Amount(p_api_version    IN  NUMBER,
                                p_init_msg_list  IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                                x_msg_count      OUT NOCOPY NUMBER,
                                x_msg_data       OUT NOCOPY VARCHAR2,
                                p_chr_id         IN okc_k_headers_b.id%TYPE,
                                p_selv_tbl       IN Okl_Streams_Pub.selv_tbl_type,
                                x_selv_tbl       OUT NOCOPY Okl_Streams_Pub.selv_tbl_type)
  RETURN VARCHAR2 IS
    l_api_name               CONSTANT VARCHAR2(30) := 'ROUND_STREAMS_AMOUNT';
    g_col_name_token         CONSTANT  VARCHAR2(200) := Okl_Api.G_COL_NAME_TOKEN;
    g_no_match_rec           CONSTANT VARCHAR2(30) := 'OKL_LLA_NO_MATCHING_RECORD';
    g_invalid_value          CONSTANT VARCHAR2(200) := 'OKL_INVALID_VALUE ';
    g_rnd_diff_lookup_type   CONSTANT fnd_lookups.lookup_type%TYPE := 'OKL_STRM_APPLY_ROUNDING_DIFF';
    g_first_lookup_code      CONSTANT fnd_lookups.lookup_code%TYPE := 'ADD_TO_FIRST';
    g_last_lookup_code       CONSTANT fnd_lookups.lookup_code%TYPE := 'ADD_TO_LAST';
    g_high_lookup_code       CONSTANT fnd_lookups.lookup_code%TYPE := 'ADD_TO_HIGH';
    x_return_status                   VARCHAR2(3)  := Okl_Api.G_RET_STS_SUCCESS;
    ln_grter_amt_ind                  NUMBER := 0;
    ln_grter_amt                      NUMBER := 0;
    ln_tot_no_rnd_amount              NUMBER := 0;
    ln_tot_rnd_amount                 NUMBER := 0;
    ln_rounded_amount                 NUMBER := 0;
    ln_rnd_diff_amount                NUMBER := 0;
    ln_diff_amount                    NUMBER := 0;
    ln_chr_id                         okc_k_headers_b.id%TYPE := p_chr_id;
    ln_org_id                         okc_k_headers_b.authoring_org_id%TYPE;
    lv_currency_code                  okc_k_headers_b.currency_code%TYPE;
    lv_diff_lookup_code               fnd_lookups.lookup_code%TYPE;
    g_stop_round_exp                  EXCEPTION;
    ln_precision1                     NUMBER;
    g_rounding_error                  EXCEPTION;
    lv_return_status    VARCHAR2(3) := Okl_Api.G_RET_STS_SUCCESS;
    --Added by kthiruva on 02-Dec-2004
    --Bug 4048047 - Start of Changes
    l_first_rec_index                 NUMBER := 0;
    l_last_rec_index                  NUMBER := 0;
    l_min_date                        DATE;
    l_max_date                        DATE;
    --Bug 4048047 - End of Changes

    -- Get the precision for the amounts to Round
      -- Depending on the Currency code
      CURSOR get_precision(p_currency_code OKC_K_HEADERS_B.CURRENCY_CODE%TYPE) IS
      SELECT PRECISION
      FROM fnd_currencies_vl
      WHERE currency_code = p_currency_code
      AND enabled_flag = 'Y'
      AND NVL(start_date_active, SYSDATE) <= SYSDATE
      AND NVL(end_date_active, SYSDATE) >= SYSDATE;

    l_selv_tbl                        Okl_Streams_Pub.selv_tbl_type := p_selv_tbl;
    -- Get the Rule to Adjust the amount either
    -- top/bottom/high_value of the PL/SQL tbl record
    CURSOR get_rnd_diff_lookup(p_lookup_type  fnd_lookups.lookup_type%TYPE)
    IS
    SELECT b.stm_apply_rounding_difference
    FROM fnd_lookups a,
         OKL_SYS_ACCT_OPTS b
    WHERE a.lookup_type = p_lookup_type
    AND a.lookup_code = b.stm_apply_rounding_difference;
    -- get the currency_code and Authoring_org_id
    -- from okc_k_headers_b
    CURSOR get_org_id(p_chr_id  okc_k_headers_b.id%TYPE)
    IS
    SELECT authoring_org_id,
           currency_code
    FROM okc_k_headers_b
    WHERE id = p_chr_id;

    -- Local Function to round the amount depending on the
    -- Currency code
    FUNCTION round_amount(p_amount        IN  NUMBER,
                          p_add_precision IN  NUMBER,
                          x_amount        OUT NOCOPY NUMBER,
                          p_currency_code IN okc_k_headers_b.currency_code%TYPE)
    RETURN VARCHAR2 AS
      lv_rounding_rule    okl_sys_acct_opts.ael_rounding_rule%TYPE;
      ln_precision        NUMBER;
      ln_amount           NUMBER := p_amount;
      ln_rounded_amount   NUMBER := 0;
      ln_pos_dot          NUMBER;
      ln_to_add           NUMBER := 1;
--      lv_return_status    VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
--      g_rounding_error    EXCEPTION;
      -- Get the Rule to Round the amount
      CURSOR get_rounding_rule IS
      SELECT stm_rounding_rule
      FROM OKL_SYS_ACCT_OPTS;
    BEGIN
      -- Get the Rule to Round the amount
      OPEN get_rounding_rule;
      FETCH get_rounding_rule INTO lv_rounding_rule;
      IF get_rounding_rule%NOTFOUND THEN
        Okl_Api.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => g_no_match_rec,
                            p_token1       => g_col_name_token,
                            p_token1_value => 'Rounding Rule');
        RAISE g_rounding_error;
      END IF;
      CLOSE get_rounding_rule;
      -- Get the precision for the amounts to Round
      -- Depending on the Currency code


      OPEN get_precision(p_currency_code => p_currency_code);
      FETCH get_precision INTO ln_precision;
      IF get_precision%NOTFOUND THEN
        Okl_Api.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => g_no_match_rec,
                            p_token1       => g_col_name_token,
                            p_token1_value => 'Currency Code');
        RAISE g_rounding_error;
      END IF;
      CLOSE get_precision;
      -- We now Processing the rounding depending
      -- on the rule we derived from the above cursor
      -- get rounding rule
      IF (lv_rounding_rule = 'UP') THEN
        ln_pos_dot := INSTR(TO_CHAR(ln_amount),'.') ;
        IF (ln_pos_dot > 0) AND
           (SUBSTR(ln_amount,ln_pos_dot+ln_precision+1 + p_add_precision,1) IS NOT NULL) THEN
          FOR i IN 1..ln_precision + p_add_precision LOOP
            ln_to_add := ln_to_add/10;
          END LOOP;
          ln_rounded_amount := ln_amount + ln_to_add;
        ELSE
          ln_rounded_amount := ln_amount;
        END IF;
        ln_rounded_amount := TRUNC(ln_rounded_amount,ln_precision + p_add_precision);
      ELSIF lv_rounding_rule = 'DOWN' THEN
        ln_rounded_amount := TRUNC(ln_amount, ln_precision + p_add_precision);
      ELSIF lv_rounding_rule = 'NEAREST' THEN
        ln_rounded_amount := ROUND(ln_amount, ln_precision + p_add_precision);
      END IF;
      x_amount := ln_rounded_amount;
      RETURN lv_return_status;
    EXCEPTION
      WHEN g_rounding_error THEN
        IF get_rounding_rule%ISOPEN THEN
          CLOSE get_rounding_rule;
        END IF;
        IF get_precision%ISOPEN THEN
          CLOSE get_precision;
        END IF;
        lv_return_status := Okl_Api.G_RET_STS_ERROR;
        RETURN lv_return_status;
      WHEN OTHERS THEN
        IF get_rounding_rule%ISOPEN THEN

          CLOSE get_rounding_rule;
        END IF;
        IF get_precision%ISOPEN THEN
          CLOSE get_precision;
        END IF;
        lv_return_status := Okl_Api.G_RET_STS_ERROR;
        RETURN lv_return_status;
    END round_amount;
  BEGIN

    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := Okl_Api.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    IF l_selv_tbl.COUNT > 0 THEN
      OPEN  get_org_id(p_chr_id => ln_chr_id);
      FETCH get_org_id INTO ln_org_id,
                            lv_currency_code;
      IF get_org_id%NOTFOUND THEN
        Okl_Api.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => g_no_match_rec,
                            p_token1       => g_col_name_token,
                            p_token1_value => 'Contract id');
        RAISE g_stop_round_exp;
      END IF;
      CLOSE get_org_id;
      -- we need to set the context since the records in
      -- OKL_SYS_ACCT_OPTS table are stored with regards to the context
      x_return_status      := Okl_Api.G_RET_STS_SUCCESS;
      -- IF we have diff btw rounding amounts
      -- now we decide by the below select stmt
      -- As to where we need to adjust the amount
      OPEN  get_rnd_diff_lookup(p_lookup_type => g_rnd_diff_lookup_type);
      FETCH get_rnd_diff_lookup INTO lv_diff_lookup_code;
      IF get_rnd_diff_lookup%NOTFOUND THEN
        Okl_Api.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => g_no_match_rec,
                            p_token1       => g_col_name_token,
                            p_token1_value => 'Rounding Diff Lookup');
        RAISE g_stop_round_exp;
      END IF;
      CLOSE get_rnd_diff_lookup;

      -- Modified by kthiruva on 02-Dec-2004
      -- Bug 4048047 - Start of Changes
      -- If the Apply Rounding Diff is ADD_TO_FIRST or ADD_TO_LAST then then the first and the last
      -- stream element records need to be determined.The first and last stream element record for
      -- a particular stream header is identified by checking for the min and max stream element date.

      IF lv_diff_lookup_code = g_first_lookup_code THEN
         l_first_rec_index := l_selv_tbl.FIRST;
         l_min_date        := l_selv_tbl(l_selv_tbl.FIRST).stream_element_date;
      ELSIF lv_diff_lookup_code = g_last_lookup_Code THEN
         l_last_rec_index  := l_selv_tbl.LAST;
         l_max_date        := l_Selv_tbl(l_selv_tbl.LAST).stream_element_date;
      END IF;
      -- Bug 4048047 - End of Changes

      -- Need to handle the -ve amount seprately
      -- since 0 is allways greater than -ve amounts
      IF lv_diff_lookup_code = g_high_lookup_code THEN
        IF SIGN(l_selv_tbl(l_selv_tbl.FIRST).amount) = -1 THEN
          ln_grter_amt :=  l_selv_tbl(l_selv_tbl.FIRST).amount;
        END IF;
      END IF;

      -- Now we scan the Stream element PL/SQL table of records
      -- Sum up all the amounts
      FOR i IN l_selv_tbl.FIRST..l_selv_tbl.LAST LOOP
        ln_tot_no_rnd_amount := ln_tot_no_rnd_amount + l_selv_tbl(i).amount;
        IF l_selv_tbl(i).amount > ln_grter_amt THEN
          ln_grter_amt := l_selv_tbl(i).amount;
          ln_grter_amt_ind := i;
        END IF;
        -- Added by kthiruva on 02-Dec-2004
        -- Bug 4048047 - Start of Changes
        -- Check to see if there is a stream element with a stream_element_date less than l_min_date.
        -- If so, the l_first_rec_index is reset.
        IF trunc(l_selv_tbl(i).stream_element_date) < trunc(l_min_date) THEN
           l_min_date        := l_selv_tbl(i).stream_element_date;
           l_first_rec_index := i;
        END IF;
        -- Check to see if there is a stream element with a stream_element_date greater than l_max_date.
        -- If so, the l_last_rec_index is reset.
        IF trunc(l_selv_tbl(i).stream_element_date) > trunc(l_max_date) THEN
           l_max_date       := l_selv_tbl(i).stream_element_date;
           l_last_rec_index := i;
        END IF;
        -- Bug 4048047 - End of Changes
      END LOOP;

      -- Get the precision for the amounts to Round
      -- Depending on the Currency code

      OPEN get_precision(p_currency_code => lv_currency_code);
      FETCH get_precision INTO ln_precision1;
      IF get_precision%NOTFOUND THEN
        Okl_Api.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => g_no_match_rec,
                            p_token1       => g_col_name_token,
                            p_token1_value => 'Currency Code');
        RAISE g_rounding_error;
      END IF;
      CLOSE get_precision;


--sgorantl(bug#3797982) start change
      ln_tot_no_rnd_amount := ROUND(ln_tot_no_rnd_amount,ln_precision1);
--sgorantl(bug#3797982) end change

      -- If the first value is 0 and ln_grter_amt = 0
      -- then we return the first record for adjustment
      IF lv_diff_lookup_code = g_high_lookup_code THEN
        IF ln_grter_amt_ind = 0 THEN
          ln_grter_amt := l_selv_tbl(l_selv_tbl.FIRST).amount;
          ln_grter_amt_ind := l_selv_tbl.FIRST;
        END IF;
      END IF;
      -- Now we scan the Stream element PL/SQL table of records
      -- Sum up all the amounts after rounding depending on currency_code
      FOR i IN l_selv_tbl.FIRST..l_selv_tbl.LAST LOOP
        x_return_status := round_amount(p_currency_code => lv_currency_code,
                                        p_add_precision => 0,
                                        p_amount        => l_selv_tbl(i).amount,
                                        x_amount        => ln_rounded_amount);
        IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
          EXIT WHEN (x_return_status <> Okl_Api.G_RET_STS_SUCCESS);
        END IF;
        ln_tot_rnd_amount := ln_tot_rnd_amount + ln_rounded_amount;
        -- We re-populate the rounded amount into the PL/SQL table of records
        -- So that we can give the same as output if there is diff
        -- btw ln_tot_no_rnd_amount and ln_tot_rnd_amount
        l_selv_tbl(i).amount := ln_rounded_amount;
      END LOOP;
      IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
        RAISE g_stop_round_exp;
      END IF;
      -- Now we will see the diff btw ln_tot_no_rnd_amount and ln_tot_rnd_amount
      -- IF there is diff then as done below
      IF ln_tot_no_rnd_amount <> ln_tot_rnd_amount THEN
        -- If the diff correction rule is First then

        IF lv_diff_lookup_code = g_first_lookup_code THEN
          -- If the Diff Amount is +ve then we add to the first record of
          -- pl/sql record of the table
          ln_diff_amount := ln_tot_no_rnd_amount - ln_tot_rnd_amount;
          -- Since the pl/sql table of records come in as not rounded
          -- and in the above we round the pl/sql table of records
          -- and since we need to do the corrections only on the rounded amont
          -- hence we need to round the ln_diff_amount variable also.
          x_return_status := round_amount(p_currency_code => lv_currency_code,
                                          p_add_precision => 0,
                                          p_amount        => ln_diff_amount,
                                          x_amount        => ln_rnd_diff_amount);
          IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
            RAISE g_stop_round_exp;
          END IF;
          IF SIGN(ln_rnd_diff_amount) = 1 THEN
            -- Modified by kthiruva on 02-Dec-2004
            -- Bug 4048047 - Start of Changes
            l_selv_tbl(l_first_rec_index).amount := l_selv_tbl(l_first_rec_index).amount + ln_rnd_diff_amount;
            --Bug 4048047 - End of Changes
          -- If the Diff Amount is -ve then we substract from the first record of
          -- pl/sql record of the table
          ELSIF SIGN(ln_rnd_diff_amount) = -1 THEN
            ln_diff_amount := ln_tot_rnd_amount- ln_tot_no_rnd_amount ;
            -- Since the pl/sql table of records come in as not rounded
            -- and in the above we round the pl/sql table of records
            -- and since we need to do the corrections only on the rounded amont
            -- hence we need to round the ln_diff_amount variable also.
            x_return_status := round_amount(p_currency_code => lv_currency_code,
                                            p_add_precision => 0,
                                            p_amount        => ln_diff_amount,
                                            x_amount        => ln_rnd_diff_amount);
            IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
              RAISE g_stop_round_exp;
            END IF;
            -- Modified by kthiruva on 02-Dec-2004
            -- Bug 4048047 - Start of Changes
            l_selv_tbl(l_first_rec_index).amount := l_selv_tbl(l_first_rec_index).amount - (ln_rnd_diff_amount);
            -- Bug 4048047 - End Of Changes
          END IF;
        -- If the diff correction rule is Last then
        ELSIF lv_diff_lookup_code = g_last_lookup_code THEN
          -- If the Diff Amount is +ve then we add to the last record of
          -- pl/sql record of the table
          ln_diff_amount := ln_tot_no_rnd_amount - ln_tot_rnd_amount;
          -- Since the pl/sql table of records come in as not rounded
          -- and in the above we round the pl/sql table of records
          -- and since we need to do the corrections only on the rounded amont
          -- hence we need to round the ln_diff_amount variable also.
          x_return_status := round_amount(p_currency_code => lv_currency_code,
                                          p_add_precision => 0,
                                          p_amount        => ln_diff_amount,
                                          x_amount        => ln_rnd_diff_amount);
          IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
            RAISE g_stop_round_exp;
          END IF;
          IF SIGN(ln_rnd_diff_amount) = 1 THEN
            -- Modified by kthiruva on 02-Dec-2004
            -- Bug 4048047 - Start of Changes
            l_selv_tbl(l_last_rec_index).amount := l_selv_tbl(l_last_rec_index).amount + (ln_rnd_diff_amount);
            -- Bug 4048047 - End of Changes
          -- If the Diff Amount is -ve then we substract from the last record of
          -- pl/sql record of the table
          ELSIF SIGN(ln_rnd_diff_amount) = -1 THEN
            ln_diff_amount := ln_tot_rnd_amount- ln_tot_no_rnd_amount ;
            -- Since the pl/sql table of records come in as not rounded
            -- and in the above we round the pl/sql table of records
            -- and since we need to do the corrections only on the rounded amont
            -- hence we need to round the ln_diff_amount variable also.
            x_return_status := round_amount(p_currency_code => lv_currency_code,
                                            p_add_precision => 0,
                                            p_amount        => ln_diff_amount,
                                            x_amount        => ln_rnd_diff_amount);
            IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
              RAISE g_stop_round_exp;
            END IF;
            -- Modified by kthiruva on 02-Dec-2004
            -- Bug 4048047 - Start of Changes
            --Modified by kthiruva for Bug 4730902 on 22-Nov-2005.
            --The amount needs to be subtracted when the diff is negative
            l_selv_tbl(l_last_rec_index).amount := l_selv_tbl(l_last_rec_index).amount - (ln_rnd_diff_amount);
            -- Bug 4048047 - End of Changes
          END IF;
        -- If the diff correction rule is High Amount then
        ELSIF lv_diff_lookup_code = g_high_lookup_code  THEN
          ln_diff_amount := ln_tot_no_rnd_amount - ln_tot_rnd_amount;
          -- Since the pl/sql table of records come in as not rounded
          -- and in the above we round the pl/sql table of records
          -- and since we need to do the corrections only on the rounded amont
          -- hence we need to round the ln_diff_amount variable also.
          x_return_status := round_amount(p_currency_code => lv_currency_code,
                                          p_add_precision => 0,
                                          p_amount        => ln_diff_amount,
                                          x_amount        => ln_rnd_diff_amount);
          IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
            RAISE g_stop_round_exp;
          END IF;
          -- If the Diff Amount is +ve then we add to the High amount record of
          -- pl/sql record of the table
          IF SIGN(ln_rnd_diff_amount) = 1 THEN
            l_selv_tbl(ln_grter_amt_ind).amount := l_selv_tbl(ln_grter_amt_ind).amount + (ln_rnd_diff_amount);
          -- If the Diff Amount is -ve then we substract from the High amount record of
          -- pl/sql record of the table
          ELSIF SIGN(ln_rnd_diff_amount) = -1 THEN
            ln_diff_amount := ln_tot_rnd_amount- ln_tot_no_rnd_amount ;
            -- Since the pl/sql table of records come in as not rounded
            -- and in the above we round the pl/sql table of records
            -- and since we need to do the corrections only on the rounded amont
            -- hence we need to round the ln_diff_amount variable also.
            x_return_status := round_amount(p_currency_code => lv_currency_code,
                                            p_add_precision => 0,
                                            p_amount        => ln_diff_amount,
                                            x_amount        => ln_rnd_diff_amount);

            IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
              RAISE g_stop_round_exp;
            END IF;
            l_selv_tbl(ln_grter_amt_ind).amount := l_selv_tbl(ln_grter_amt_ind).amount - (ln_rnd_diff_amount);
          END IF;
        END IF;
        -- There is diff so we set the o/p record with modified record derived above
        x_selv_tbl := l_selv_tbl;
      ELSIF ln_tot_no_rnd_amount = ln_tot_rnd_amount THEN
        -- There is no diff so we set the i/p record back o/p record
        --Modified by dpsingh on 02-Feb-2006.          x_selv_tbl := p_selv_tbl;
         --Even when there is no rounding diff, the rounded table l_selv_tbl should only be returned
         --The unrounded table is being returned incorrectly
         --Bug 4559800(H) - Start of Changes
         x_selv_tbl := l_selv_tbl;
         --Bug 4559800(H) - End of Changes
      END IF;
    ELSE
      Okl_Api.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_INVALID_VALUE,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'p_selv_tbl');
      RAISE g_stop_round_exp;
    END IF;

    Okl_Api.END_ACTIVITY (x_msg_count,
                          x_msg_data );
    RETURN x_return_status;
  EXCEPTION
     WHEN g_rounding_error THEN
        IF get_precision%ISOPEN THEN
          CLOSE get_precision;
        END IF;
        lv_return_status := Okl_Api.G_RET_STS_ERROR;
        RETURN lv_return_status;
    WHEN g_stop_round_exp THEN
      IF get_rnd_diff_lookup%ISOPEN THEN
        CLOSE get_rnd_diff_lookup;
      END IF;
      IF get_org_id%ISOPEN THEN
        CLOSE get_org_id;
      END IF;
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OKL_API.G_RET_STS_ERROR',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
      RETURN x_return_status;
    WHEN OTHERS THEN
      IF get_rnd_diff_lookup%ISOPEN THEN
        CLOSE get_rnd_diff_lookup;
      END IF;
      IF get_org_id%ISOPEN THEN
        CLOSE get_org_id;
      END IF;
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS(
                                l_api_name,
                                G_PKG_NAME,
                                'OTHERS',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');
      RETURN x_return_status;
  END Round_Streams_Amount;
-- BAKUCHIB Bug 2835092 End


PROCEDURE get_primary_stream_type
(
 p_khr_id  		   	     IN okl_k_headers_full_v.id%TYPE,
 p_primary_sty_purpose   IN okl_strm_type_b.STREAM_TYPE_PURPOSE%TYPE,
 x_return_status		OUT NOCOPY VARCHAR2,
 x_primary_sty_id 		OUT NOCOPY okl_strm_type_b.ID%TYPE
)

IS

CURSOR cntrct_csr (l_khr_id NUMBER)IS
SELECT pdt_id, start_date
FROM     okl_k_headers_full_v
WHERE id = l_khr_id;

CURSOR pry_sty_csr (l_pdt_id NUMBER, l_contract_start_date DATE) IS
SELECT PRIMARY_STY_ID
FROM   OKL_STRM_TMPT_LINES_UV STL
WHERE STL.PRIMARY_YN = 'Y'
AND STL.PDT_ID = l_pdt_id
AND    (STL.START_DATE <= l_contract_start_date)
AND    (STL.END_DATE >= l_contract_start_date OR STL.END_DATE IS NULL)
AND	   PRIMARY_STY_PURPOSE =   p_primary_sty_purpose;

  l_product_id 			  					NUMBER;
  l_contract_start_date 	DATE;
  l_primary_sty_id 			  	NUMBER;

  -- Santonyr Bug 4056364

  l_primary_sty_purpose_meaning VARCHAR2(4000);


BEGIN

  x_return_status         := Okl_Api.G_RET_STS_SUCCESS;


  OPEN cntrct_csr (p_khr_id);
  FETCH cntrct_csr INTO l_product_id, l_contract_start_date;
  CLOSE cntrct_csr;



  IF (l_product_id IS NOT NULL) AND (l_contract_start_date IS NOT NULL) THEN

    OPEN pry_sty_csr (l_product_id, l_contract_start_date);
    FETCH pry_sty_csr INTO l_primary_sty_id;
      IF  pry_sty_csr%NOTFOUND THEN

-- Santonyr Bug 4056364
-- Bug 4064253

            l_primary_sty_purpose_meaning := OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING
            			('OKL_STREAM_TYPE_PURPOSE', p_primary_sty_purpose);

            OKL_API.SET_MESSAGE(p_app_name      => g_app_name,
                                p_msg_name      => 'OKL_NO_PRY_STY_FOUND',
                                p_token1        => 'PURPOSE',
                                p_token1_value  => l_primary_sty_purpose_meaning);
            RAISE Okl_Api.G_EXCEPTION_ERROR;
	 END IF;
     CLOSE pry_sty_csr;

  ELSE

	        Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_NO_PDT_FOUND');
            RAISE Okl_Api.G_EXCEPTION_ERROR;

  END IF;

  x_primary_sty_id := l_primary_sty_id;

  EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
     IF cntrct_csr%ISOPEN THEN
	    CLOSE cntrct_csr;
	 END IF;
     IF pry_sty_csr%ISOPEN THEN
	    CLOSE pry_sty_csr;
	 END IF;
     x_return_status := Okl_Api.G_RET_STS_ERROR ;

  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
     IF cntrct_csr%ISOPEN THEN
	    CLOSE cntrct_csr;
	 END IF;
     IF pry_sty_csr%ISOPEN THEN
	    CLOSE pry_sty_csr;
	 END IF;
     x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN
     IF cntrct_csr%ISOPEN THEN
	    CLOSE cntrct_csr;
	 END IF;
     IF pry_sty_csr%ISOPEN THEN
	    CLOSE pry_sty_csr;
	 END IF;
     x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      --DBMS_OUTPUT.PUT_LINE(SQLERRM);

END get_primary_stream_type;

PROCEDURE get_primary_stream_type
(
 p_khr_id  		   	     IN okl_k_headers_full_v.id%TYPE,
 p_primary_sty_purpose   IN okl_strm_type_b.STREAM_TYPE_PURPOSE%TYPE,
 x_return_status		OUT NOCOPY VARCHAR2,
 x_primary_sty_id 		OUT NOCOPY okl_strm_type_id_tbl_type
)

IS

CURSOR cntrct_csr (l_khr_id NUMBER)IS
SELECT pdt_id, start_date
FROM     okl_k_headers_full_v
WHERE id = l_khr_id;

CURSOR pry_sty_csr (l_pdt_id NUMBER, l_contract_start_date DATE) IS
SELECT PRIMARY_STY_ID
FROM   OKL_STRM_TMPT_LINES_UV STL
WHERE STL.PRIMARY_YN = 'Y'
AND STL.PDT_ID = l_pdt_id
AND    (STL.START_DATE <= l_contract_start_date)
AND    (STL.END_DATE >= l_contract_start_date OR STL.END_DATE IS NULL)
AND	   PRIMARY_STY_PURPOSE =   p_primary_sty_purpose;

  l_product_id 			  					NUMBER;
  l_contract_start_date 	DATE;
  l_primary_sty_id 			  	NUMBER;
-- Santonyr Bug 4056364
  l_primary_sty_purpose_meaning VARCHAR2(4000);

BEGIN

  x_return_status         := Okl_Api.G_RET_STS_SUCCESS;


  OPEN cntrct_csr (p_khr_id);
  FETCH cntrct_csr INTO l_product_id, l_contract_start_date;
  CLOSE cntrct_csr;



  IF (l_product_id IS NOT NULL) AND (l_contract_start_date IS NOT NULL) THEN

    OPEN pry_sty_csr (l_product_id, l_contract_start_date);
    FETCH pry_sty_csr INTO l_primary_sty_id;
      IF  pry_sty_csr%NOTFOUND THEN
            l_primary_sty_purpose_meaning := OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING
            			('OKL_STREAM_TYPE_PURPOSE', p_primary_sty_purpose);
      -- Bug 4064253

            OKL_API.SET_MESSAGE(p_app_name      => g_app_name,
                                p_msg_name      => 'OKL_NO_PRY_STY_FOUND',
                                p_token1        => 'PURPOSE',
                                p_token1_value  => l_primary_sty_purpose_meaning);
            RAISE Okl_Api.G_EXCEPTION_ERROR;
	 END IF;
     CLOSE pry_sty_csr;

  ELSE

	        Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_NO_PDT_FOUND');
            RAISE Okl_Api.G_EXCEPTION_ERROR;

  END IF;

  --x_primary_sty_id := l_primary_sty_id;

  EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
     IF cntrct_csr%ISOPEN THEN
	    CLOSE cntrct_csr;
	 END IF;
     IF pry_sty_csr%ISOPEN THEN
	    CLOSE pry_sty_csr;
	 END IF;
     x_return_status := Okl_Api.G_RET_STS_ERROR ;

  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
     IF cntrct_csr%ISOPEN THEN
	    CLOSE cntrct_csr;
	 END IF;
     IF pry_sty_csr%ISOPEN THEN
	    CLOSE pry_sty_csr;
	 END IF;
     x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN
     IF cntrct_csr%ISOPEN THEN
	    CLOSE cntrct_csr;
	 END IF;
     IF pry_sty_csr%ISOPEN THEN
	    CLOSE pry_sty_csr;
	 END IF;
     x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      --DBMS_OUTPUT.PUT_LINE(SQLERRM);

END get_primary_stream_type;

PROCEDURE get_primary_stream_type_rep
(
 p_khr_id  		   	     IN okl_k_headers_full_v.id%TYPE,
 p_primary_sty_purpose   IN okl_strm_type_b.STREAM_TYPE_PURPOSE%TYPE,
 x_return_status		OUT NOCOPY VARCHAR2,
 x_primary_sty_id 		OUT NOCOPY okl_strm_type_b.ID%TYPE
)

IS

CURSOR cntrct_csr (l_khr_id NUMBER)IS
SELECT pdt.reporting_pdt_id, khr.start_date
FROM     okl_k_headers_full_v khr, okl_products pdt
WHERE khr.id = l_khr_id
AND   khr.pdt_id = pdt.id;

CURSOR pry_sty_csr (l_pdt_id NUMBER, l_contract_start_date DATE) IS
SELECT PRIMARY_STY_ID
FROM   OKL_STRM_TMPT_LINES_UV STL
WHERE STL.PRIMARY_YN = 'Y'
AND STL.PDT_ID = l_pdt_id
AND    (STL.START_DATE <= l_contract_start_date)
AND    (STL.END_DATE >= l_contract_start_date OR STL.END_DATE IS NULL)
AND	   PRIMARY_STY_PURPOSE =   p_primary_sty_purpose;

  l_product_id 			  					NUMBER;
  l_contract_start_date 	DATE;
  l_primary_sty_id 			  	NUMBER;

  -- Santonyr Bug 4056364

  l_primary_sty_purpose_meaning VARCHAR2(4000);


BEGIN

  x_return_status         := Okl_Api.G_RET_STS_SUCCESS;


  OPEN cntrct_csr (p_khr_id);
  FETCH cntrct_csr INTO l_product_id, l_contract_start_date;
  CLOSE cntrct_csr;



  IF (l_product_id IS NOT NULL) AND (l_contract_start_date IS NOT NULL) THEN

    OPEN pry_sty_csr (l_product_id, l_contract_start_date);
    FETCH pry_sty_csr INTO l_primary_sty_id;
      IF  pry_sty_csr%NOTFOUND THEN

-- Santonyr Bug 4056364
-- Bug 4064253

            l_primary_sty_purpose_meaning := OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING
            			('OKL_STREAM_TYPE_PURPOSE', p_primary_sty_purpose);

            OKL_API.SET_MESSAGE(p_app_name      => g_app_name,
                                p_msg_name      => 'OKL_NO_PRY_STY_FOUND',
                                p_token1        => 'PURPOSE',
                                p_token1_value  => l_primary_sty_purpose_meaning);
            RAISE Okl_Api.G_EXCEPTION_ERROR;
	 END IF;
     CLOSE pry_sty_csr;

  ELSE

	        Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_NO_PDT_FOUND');
            RAISE Okl_Api.G_EXCEPTION_ERROR;

  END IF;

  x_primary_sty_id := l_primary_sty_id;

  EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
     IF cntrct_csr%ISOPEN THEN
	    CLOSE cntrct_csr;
	 END IF;
     IF pry_sty_csr%ISOPEN THEN
	    CLOSE pry_sty_csr;
	 END IF;
     x_return_status := Okl_Api.G_RET_STS_ERROR ;

  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
     IF cntrct_csr%ISOPEN THEN
	    CLOSE cntrct_csr;
	 END IF;
     IF pry_sty_csr%ISOPEN THEN
	    CLOSE pry_sty_csr;
	 END IF;
     x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN
     IF cntrct_csr%ISOPEN THEN
	    CLOSE cntrct_csr;
	 END IF;
     IF pry_sty_csr%ISOPEN THEN
	    CLOSE pry_sty_csr;
	 END IF;
     x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      --DBMS_OUTPUT.PUT_LINE(SQLERRM);

END get_primary_stream_type_rep;

PROCEDURE get_primary_stream_type_rep
(
 p_khr_id  		   	     IN okl_k_headers_full_v.id%TYPE,
 p_primary_sty_purpose   IN okl_strm_type_b.STREAM_TYPE_PURPOSE%TYPE,
 x_return_status		OUT NOCOPY VARCHAR2,
 x_primary_sty_id 		OUT NOCOPY okl_strm_type_id_tbl_type
)

IS

CURSOR cntrct_csr (l_khr_id NUMBER)IS
SELECT pdt.reporting_pdt_id, khr.start_date
FROM     okl_k_headers_full_v khr, okl_products pdt
WHERE khr.id = l_khr_id
AND   khr.pdt_id = pdt.id;

CURSOR pry_sty_csr (l_pdt_id NUMBER, l_contract_start_date DATE) IS
SELECT PRIMARY_STY_ID
FROM   OKL_STRM_TMPT_LINES_UV STL
WHERE STL.PRIMARY_YN = 'Y'
AND STL.PDT_ID = l_pdt_id
AND    (STL.START_DATE <= l_contract_start_date)
AND    (STL.END_DATE >= l_contract_start_date OR STL.END_DATE IS NULL)
AND	   PRIMARY_STY_PURPOSE =   p_primary_sty_purpose;

  l_product_id 			  					NUMBER;
  l_contract_start_date 	DATE;
  l_primary_sty_id 			  	NUMBER;
-- Santonyr Bug 4056364
  l_primary_sty_purpose_meaning VARCHAR2(4000);

BEGIN

  x_return_status         := Okl_Api.G_RET_STS_SUCCESS;


  OPEN cntrct_csr (p_khr_id);
  FETCH cntrct_csr INTO l_product_id, l_contract_start_date;
  CLOSE cntrct_csr;



  IF (l_product_id IS NOT NULL) AND (l_contract_start_date IS NOT NULL) THEN

    OPEN pry_sty_csr (l_product_id, l_contract_start_date);
    FETCH pry_sty_csr INTO l_primary_sty_id;
      IF  pry_sty_csr%NOTFOUND THEN
            l_primary_sty_purpose_meaning := OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING
            			('OKL_STREAM_TYPE_PURPOSE', p_primary_sty_purpose);
      -- Bug 4064253

            OKL_API.SET_MESSAGE(p_app_name      => g_app_name,
                                p_msg_name      => 'OKL_NO_PRY_STY_FOUND',
                                p_token1        => 'PURPOSE',
                                p_token1_value  => l_primary_sty_purpose_meaning);
            RAISE Okl_Api.G_EXCEPTION_ERROR;
	 END IF;
     CLOSE pry_sty_csr;

  ELSE

	        Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_NO_PDT_FOUND');
            RAISE Okl_Api.G_EXCEPTION_ERROR;

  END IF;

  --x_primary_sty_id := l_primary_sty_id;

  EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
     IF cntrct_csr%ISOPEN THEN
	    CLOSE cntrct_csr;
	 END IF;
     IF pry_sty_csr%ISOPEN THEN
	    CLOSE pry_sty_csr;
	 END IF;
     x_return_status := Okl_Api.G_RET_STS_ERROR ;

  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
     IF cntrct_csr%ISOPEN THEN
	    CLOSE cntrct_csr;
	 END IF;
     IF pry_sty_csr%ISOPEN THEN
	    CLOSE pry_sty_csr;
	 END IF;
     x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN
     IF cntrct_csr%ISOPEN THEN
	    CLOSE cntrct_csr;
	 END IF;
     IF pry_sty_csr%ISOPEN THEN
	    CLOSE pry_sty_csr;
	 END IF;
     x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      --DBMS_OUTPUT.PUT_LINE(SQLERRM);

END get_primary_stream_type_rep;

PROCEDURE get_dependent_stream_type
(
 p_khr_id  		   	     IN okl_k_headers_full_v.id%TYPE,
 p_primary_sty_purpose   IN okl_strm_type_b.STREAM_TYPE_PURPOSE%TYPE,
 p_dependent_sty_purpose IN okl_strm_type_b.STREAM_TYPE_PURPOSE%TYPE,
 x_return_status		 OUT NOCOPY VARCHAR2,
 x_dependent_sty_id 	 OUT NOCOPY okl_strm_type_b.ID%TYPE
)

IS

CURSOR cntrct_csr (l_khr_id NUMBER)IS
SELECT pdt_id, start_date
FROM     okl_k_headers_full_v
WHERE id = l_khr_id;

CURSOR dep_sty_csr (l_product_id NUMBER, l_contract_start_date DATE) IS
SELECT DEPENDENT_STY_ID
FROM   OKL_STRM_TMPT_LINES_UV STL
WHERE PRIMARY_YN = 'N'
AND STL.PDT_ID = l_product_id
AND    (STL.START_DATE <= l_contract_start_date)
AND   (STL.END_DATE >= l_contract_start_date OR STL.END_DATE IS NULL)
AND	   PRIMARY_STY_PURPOSE =   p_primary_sty_purpose
AND	   DEPENDENT_STY_PURPOSE =   p_dependent_sty_purpose;

  l_product_id 			  					NUMBER;
  l_contract_start_date 	DATE;
  l_dependetn_sty_id 			  					NUMBER;

-- Santonyr Bug 4056364

  l_dep_sty_purpose_meaning VARCHAR2(4000);

BEGIN

  x_return_status         := Okl_Api.G_RET_STS_SUCCESS;

--  DBMS_OUTPUT.PUT_LINE('l_p_khr_id -  ' || p_khr_id);

  OPEN cntrct_csr (p_khr_id);
  FETCH cntrct_csr INTO l_product_id, l_contract_start_date;
  CLOSE cntrct_csr;

--  DBMS_OUTPUT.PUT_LINE('l_pdt_id -  ' || l_product_id);
--  DBMS_OUTPUT.PUT_LINE('l_start_date -  ' || l_contract_start_date);

  IF (l_product_id IS NOT NULL) AND (l_contract_start_date IS NOT NULL) THEN

    OPEN dep_sty_csr (l_product_id, l_contract_start_date);
    FETCH dep_sty_csr INTO l_dependetn_sty_id;
      IF  dep_sty_csr%NOTFOUND THEN
-- Santonyr Bug 4056364
            l_dep_sty_purpose_meaning := OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING
            			('OKL_STREAM_TYPE_PURPOSE', p_dependent_sty_purpose);
            OKL_API.SET_MESSAGE(p_app_name      => g_app_name,
                                p_msg_name      => 'OKL_NO_DEP_STY_FOUND',
                                p_token1        => 'PURPOSE',
                                p_token1_value  => l_dep_sty_purpose_meaning);
            RAISE Okl_Api.G_EXCEPTION_ERROR;
	 END IF;
     CLOSE dep_sty_csr;

  ELSE

	        Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_NO_PDT_FOUND');
            RAISE Okl_Api.G_EXCEPTION_ERROR;

  END IF;

  x_dependent_sty_id := l_dependetn_sty_id;

  EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
     IF cntrct_csr%ISOPEN THEN
	    CLOSE cntrct_csr;
	 END IF;
     IF dep_sty_csr%ISOPEN THEN
	    CLOSE dep_sty_csr;
	 END IF;
     x_return_status := Okl_Api.G_RET_STS_ERROR ;

  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
     IF cntrct_csr%ISOPEN THEN
	    CLOSE cntrct_csr;
	 END IF;
     IF dep_sty_csr%ISOPEN THEN
	    CLOSE dep_sty_csr;
	 END IF;
     x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN
     IF cntrct_csr%ISOPEN THEN
	    CLOSE cntrct_csr;
	 END IF;
     IF dep_sty_csr%ISOPEN THEN
	    CLOSE dep_sty_csr;
	 END IF;
     x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      --DBMS_OUTPUT.PUT_LINE(SQLERRM);
END get_dependent_stream_type;


PROCEDURE get_dependent_stream_type
(
 p_khr_id  		   	     IN okl_k_headers_full_v.id%TYPE,
 p_primary_sty_id        IN okl_strm_type_b.ID%TYPE,
 p_dependent_sty_purpose IN okl_strm_type_b.STREAM_TYPE_PURPOSE%TYPE,
 x_return_status		 OUT NOCOPY VARCHAR2,
 x_dependent_sty_id 	 OUT NOCOPY okl_strm_type_b.ID%TYPE
)

IS

CURSOR cntrct_csr (l_khr_id NUMBER)IS
SELECT pdt_id, start_date
FROM     okl_k_headers_full_v
WHERE id = l_khr_id;

CURSOR dep_sty_csr (l_product_id NUMBER, l_contract_start_date DATE) IS
SELECT DEPENDENT_STY_ID
FROM   OKL_STRM_TMPT_LINES_UV STL
WHERE PRIMARY_YN = 'N'
AND STL.PDT_ID = l_product_id
AND    (STL.START_DATE <= l_contract_start_date)
AND   (STL.END_DATE >= l_contract_start_date OR STL.END_DATE IS NULL)
AND	   PRIMARY_STY_ID =   p_primary_sty_id
AND	   DEPENDENT_STY_PURPOSE =   p_dependent_sty_purpose;

  l_product_id 			  					NUMBER;
  l_contract_start_date 	DATE;
  l_dependetn_sty_id 			  					NUMBER;

-- Santonyr Bug 4056364
  l_dep_sty_purpose_meaning VARCHAR2(4000);

BEGIN

  x_return_status         := Okl_Api.G_RET_STS_SUCCESS;

--  DBMS_OUTPUT.PUT_LINE('l_p_khr_id -  ' || p_khr_id);

  OPEN cntrct_csr (p_khr_id);
  FETCH cntrct_csr INTO l_product_id, l_contract_start_date;
  CLOSE cntrct_csr;

--  DBMS_OUTPUT.PUT_LINE('l_pdt_id -  ' || l_product_id);
--  DBMS_OUTPUT.PUT_LINE('l_start_date -  ' || l_contract_start_date);

  IF (l_product_id IS NOT NULL) AND (l_contract_start_date IS NOT NULL) THEN
--dbms_output.put_line('Product Id5'||l_product_id);
	--dbms_output.put_line('Contract Strat Date5'||l_contract_start_date);
    OPEN dep_sty_csr (l_product_id, l_contract_start_date);
    FETCH dep_sty_csr INTO l_dependetn_sty_id;
      IF  dep_sty_csr%NOTFOUND THEN

-- Santonyr Bug 4056364
            l_dep_sty_purpose_meaning := OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING
            			('OKL_STREAM_TYPE_PURPOSE', p_dependent_sty_purpose);

            OKL_API.SET_MESSAGE(p_app_name      => g_app_name,
                                p_msg_name      => 'OKL_NO_DEP_STY_FOUND',
                                p_token1        => 'PURPOSE',
                                p_token1_value  => l_dep_sty_purpose_meaning);

            RAISE Okl_Api.G_EXCEPTION_ERROR;
	 END IF;
     CLOSE dep_sty_csr;

  ELSE

	        Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_NO_PDT_FOUND');
            RAISE Okl_Api.G_EXCEPTION_ERROR;

  END IF;

  x_dependent_sty_id := l_dependetn_sty_id;

  EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
     IF cntrct_csr%ISOPEN THEN
	    CLOSE cntrct_csr;
	 END IF;
     IF dep_sty_csr%ISOPEN THEN
	    CLOSE dep_sty_csr;
	 END IF;
     x_return_status := Okl_Api.G_RET_STS_ERROR ;

  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
     IF cntrct_csr%ISOPEN THEN
	    CLOSE cntrct_csr;
	 END IF;
     IF dep_sty_csr%ISOPEN THEN
	    CLOSE dep_sty_csr;
	 END IF;
     x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN
     IF cntrct_csr%ISOPEN THEN
	    CLOSE cntrct_csr;
	 END IF;
     IF dep_sty_csr%ISOPEN THEN
	    CLOSE dep_sty_csr;
	 END IF;
     x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      --DBMS_OUTPUT.PUT_LINE(SQLERRM);
END get_dependent_stream_type;

-- Added for bug 6326479  - start
PROCEDURE get_dependent_stream_type
(
 p_khr_id  		 IN okl_k_headers_full_v.id%TYPE,
 p_product_id            IN okl_k_headers_full_v.pdt_id%TYPE,
 p_primary_sty_purpose   IN okl_strm_type_b.STREAM_TYPE_PURPOSE%TYPE,
 p_dependent_sty_purpose IN okl_strm_type_b.STREAM_TYPE_PURPOSE%TYPE,
 x_return_status	 OUT NOCOPY VARCHAR2,
 x_dependent_sty_id 	 OUT NOCOPY okl_strm_type_b.ID%TYPE
)

IS

CURSOR cntrct_csr (l_khr_id NUMBER)IS
SELECT pdt_id, start_date
FROM     okl_k_headers_full_v
WHERE id = l_khr_id;

CURSOR dep_sty_csr (l_product_id NUMBER, l_contract_start_date DATE) IS
SELECT DEPENDENT_STY_ID
FROM   OKL_STRM_TMPT_LINES_UV STL
WHERE PRIMARY_YN = 'N'
AND STL.PDT_ID = l_product_id
AND    (STL.START_DATE <= l_contract_start_date)
AND   (STL.END_DATE >= l_contract_start_date OR STL.END_DATE IS NULL)
AND	   PRIMARY_STY_PURPOSE =   p_primary_sty_purpose
AND	   DEPENDENT_STY_PURPOSE =   p_dependent_sty_purpose;

  l_product_id 			  					NUMBER;
  l_contract_start_date 	DATE;
  l_dependetn_sty_id 			  					NUMBER;

-- Santonyr Bug 4056364

  l_dep_sty_purpose_meaning VARCHAR2(4000);

BEGIN

  x_return_status         := Okl_Api.G_RET_STS_SUCCESS;

  OPEN cntrct_csr (p_khr_id);
  FETCH cntrct_csr INTO l_product_id, l_contract_start_date;
  CLOSE cntrct_csr;

  IF (p_product_id IS NOT NULL) AND (l_contract_start_date IS NOT NULL) THEN

    OPEN dep_sty_csr (p_product_id, l_contract_start_date);
    FETCH dep_sty_csr INTO l_dependetn_sty_id;
      IF  dep_sty_csr%NOTFOUND THEN

            l_dep_sty_purpose_meaning := OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING
            			('OKL_STREAM_TYPE_PURPOSE', p_dependent_sty_purpose);
            OKL_API.SET_MESSAGE(p_app_name      => g_app_name,
                                p_msg_name      => 'OKL_NO_DEP_STY_FOUND',
                                p_token1        => 'PURPOSE',
                                p_token1_value  => l_dep_sty_purpose_meaning);
            RAISE Okl_Api.G_EXCEPTION_ERROR;
	 END IF;
     CLOSE dep_sty_csr;

  ELSE
	        Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_NO_PDT_FOUND');
            RAISE Okl_Api.G_EXCEPTION_ERROR;

  END IF;

  x_dependent_sty_id := l_dependetn_sty_id;

  EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
     IF cntrct_csr%ISOPEN THEN
	    CLOSE cntrct_csr;
	 END IF;
     IF dep_sty_csr%ISOPEN THEN
	    CLOSE dep_sty_csr;
	 END IF;
     x_return_status := Okl_Api.G_RET_STS_ERROR ;

  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
     IF cntrct_csr%ISOPEN THEN
	    CLOSE cntrct_csr;
	 END IF;
     IF dep_sty_csr%ISOPEN THEN
	    CLOSE dep_sty_csr;
	 END IF;
     x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN
     IF cntrct_csr%ISOPEN THEN
	    CLOSE cntrct_csr;
	 END IF;
     IF dep_sty_csr%ISOPEN THEN
	    CLOSE dep_sty_csr;
	 END IF;
     x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
END get_dependent_stream_type;

PROCEDURE get_dependent_stream_type_rep
(
 p_khr_id  		   	     IN okl_k_headers_full_v.id%TYPE,
 p_primary_sty_purpose   IN okl_strm_type_b.STREAM_TYPE_PURPOSE%TYPE,
 p_dependent_sty_purpose IN okl_strm_type_b.STREAM_TYPE_PURPOSE%TYPE,
 x_return_status		 OUT NOCOPY VARCHAR2,
 x_dependent_sty_id 	 OUT NOCOPY okl_strm_type_b.ID%TYPE
)

IS

CURSOR cntrct_csr (l_khr_id NUMBER)IS
SELECT pdt.reporting_pdt_id, khr.start_date
FROM     okl_k_headers_full_v khr, okl_products pdt
WHERE khr.id = l_khr_id
AND   khr.pdt_id = pdt.id;

CURSOR dep_sty_csr (l_product_id NUMBER, l_contract_start_date DATE) IS
SELECT DEPENDENT_STY_ID
FROM   OKL_STRM_TMPT_LINES_UV STL
WHERE PRIMARY_YN = 'N'
AND STL.PDT_ID = l_product_id
AND    (STL.START_DATE <= l_contract_start_date)
AND   (STL.END_DATE >= l_contract_start_date OR STL.END_DATE IS NULL)
AND	   PRIMARY_STY_PURPOSE =   p_primary_sty_purpose
AND	   DEPENDENT_STY_PURPOSE =   p_dependent_sty_purpose;

  l_product_id 			  					NUMBER;
  l_contract_start_date 	DATE;
  l_dependetn_sty_id 			  					NUMBER;

-- Santonyr Bug 4056364

  l_dep_sty_purpose_meaning VARCHAR2(4000);

BEGIN

  x_return_status         := Okl_Api.G_RET_STS_SUCCESS;

--  DBMS_OUTPUT.PUT_LINE('l_p_khr_id -  ' || p_khr_id);

  OPEN cntrct_csr (p_khr_id);
  FETCH cntrct_csr INTO l_product_id, l_contract_start_date;
  CLOSE cntrct_csr;

--  DBMS_OUTPUT.PUT_LINE('l_pdt_id -  ' || l_product_id);
--  DBMS_OUTPUT.PUT_LINE('l_start_date -  ' || l_contract_start_date);

  IF (l_product_id IS NOT NULL) AND (l_contract_start_date IS NOT NULL) THEN

    OPEN dep_sty_csr (l_product_id, l_contract_start_date);
    FETCH dep_sty_csr INTO l_dependetn_sty_id;
      IF  dep_sty_csr%NOTFOUND THEN
-- Santonyr Bug 4056364
            l_dep_sty_purpose_meaning := OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING
            			('OKL_STREAM_TYPE_PURPOSE', p_dependent_sty_purpose);
            OKL_API.SET_MESSAGE(p_app_name      => g_app_name,
                                p_msg_name      => 'OKL_NO_DEP_STY_FOUND',
                                p_token1        => 'PURPOSE',
                                p_token1_value  => l_dep_sty_purpose_meaning);
            RAISE Okl_Api.G_EXCEPTION_ERROR;
	 END IF;
     CLOSE dep_sty_csr;

  ELSE

	        Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_NO_PDT_FOUND');
            RAISE Okl_Api.G_EXCEPTION_ERROR;

  END IF;

  x_dependent_sty_id := l_dependetn_sty_id;

  EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
     IF cntrct_csr%ISOPEN THEN
	    CLOSE cntrct_csr;
	 END IF;
     IF dep_sty_csr%ISOPEN THEN
	    CLOSE dep_sty_csr;
	 END IF;
     x_return_status := Okl_Api.G_RET_STS_ERROR ;

  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
     IF cntrct_csr%ISOPEN THEN
	    CLOSE cntrct_csr;
	 END IF;
     IF dep_sty_csr%ISOPEN THEN
	    CLOSE dep_sty_csr;
	 END IF;
     x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN
     IF cntrct_csr%ISOPEN THEN
	    CLOSE cntrct_csr;
	 END IF;
     IF dep_sty_csr%ISOPEN THEN
	    CLOSE dep_sty_csr;
	 END IF;
     x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      --DBMS_OUTPUT.PUT_LINE(SQLERRM);
END get_dependent_stream_type_rep;


PROCEDURE get_dependent_stream_type_rep
(
 p_khr_id  		   	     IN okl_k_headers_full_v.id%TYPE,
 p_primary_sty_id        IN okl_strm_type_b.ID%TYPE,
 p_dependent_sty_purpose IN okl_strm_type_b.STREAM_TYPE_PURPOSE%TYPE,
 x_return_status		 OUT NOCOPY VARCHAR2,
 x_dependent_sty_id 	 OUT NOCOPY okl_strm_type_b.ID%TYPE
)

IS

CURSOR cntrct_csr (l_khr_id NUMBER)IS
SELECT pdt.reporting_pdt_id, khr.start_date
FROM     okl_k_headers_full_v khr, okl_products pdt
WHERE khr.id = l_khr_id
AND   khr.pdt_id = pdt.id;

CURSOR dep_sty_csr (l_product_id NUMBER, l_contract_start_date DATE) IS
SELECT DEPENDENT_STY_ID
FROM   OKL_STRM_TMPT_LINES_UV STL
WHERE PRIMARY_YN = 'N'
AND STL.PDT_ID = l_product_id
AND    (STL.START_DATE <= l_contract_start_date)
AND   (STL.END_DATE >= l_contract_start_date OR STL.END_DATE IS NULL)
AND	   PRIMARY_STY_ID =   p_primary_sty_id
AND	   DEPENDENT_STY_PURPOSE =   p_dependent_sty_purpose;

  l_product_id 			  					NUMBER;
  l_contract_start_date 	DATE;
  l_dependetn_sty_id 			  					NUMBER;

-- Santonyr Bug 4056364
  l_dep_sty_purpose_meaning VARCHAR2(4000);

BEGIN

  x_return_status         := Okl_Api.G_RET_STS_SUCCESS;

--  DBMS_OUTPUT.PUT_LINE('l_p_khr_id -  ' || p_khr_id);

  OPEN cntrct_csr (p_khr_id);
  FETCH cntrct_csr INTO l_product_id, l_contract_start_date;
  CLOSE cntrct_csr;

--  DBMS_OUTPUT.PUT_LINE('l_pdt_id -  ' || l_product_id);
--  DBMS_OUTPUT.PUT_LINE('l_start_date -  ' || l_contract_start_date);

  IF (l_product_id IS NOT NULL) AND (l_contract_start_date IS NOT NULL) THEN
--dbms_output.put_line('Product Id5'||l_product_id);
	--dbms_output.put_line('Contract Strat Date5'||l_contract_start_date);
    OPEN dep_sty_csr (l_product_id, l_contract_start_date);
    FETCH dep_sty_csr INTO l_dependetn_sty_id;
      IF  dep_sty_csr%NOTFOUND THEN

-- Santonyr Bug 4056364
            l_dep_sty_purpose_meaning := OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING
            			('OKL_STREAM_TYPE_PURPOSE', p_dependent_sty_purpose);

            OKL_API.SET_MESSAGE(p_app_name      => g_app_name,
                                p_msg_name      => 'OKL_NO_DEP_STY_FOUND',
                                p_token1        => 'PURPOSE',
                                p_token1_value  => l_dep_sty_purpose_meaning);

            RAISE Okl_Api.G_EXCEPTION_ERROR;
	 END IF;
     CLOSE dep_sty_csr;

  ELSE

	        Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_NO_PDT_FOUND');
            RAISE Okl_Api.G_EXCEPTION_ERROR;

  END IF;

  x_dependent_sty_id := l_dependetn_sty_id;

  EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
     IF cntrct_csr%ISOPEN THEN
	    CLOSE cntrct_csr;
	 END IF;
     IF dep_sty_csr%ISOPEN THEN
	    CLOSE dep_sty_csr;
	 END IF;
     x_return_status := Okl_Api.G_RET_STS_ERROR ;

  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
     IF cntrct_csr%ISOPEN THEN
	    CLOSE cntrct_csr;
	 END IF;
     IF dep_sty_csr%ISOPEN THEN
	    CLOSE dep_sty_csr;
	 END IF;
     x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN
     IF cntrct_csr%ISOPEN THEN
	    CLOSE cntrct_csr;
	 END IF;
     IF dep_sty_csr%ISOPEN THEN
	    CLOSE dep_sty_csr;
	 END IF;
     x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      --DBMS_OUTPUT.PUT_LINE(SQLERRM);
END get_dependent_stream_type_rep;

-- Added for bug 6326479  - start
PROCEDURE get_dependent_stream_type_rep
(
 p_khr_id  		 IN okl_k_headers_full_v.id%TYPE,
 p_product_id            IN okl_k_headers_full_v.pdt_id%TYPE,
 p_primary_sty_purpose   IN okl_strm_type_b.STREAM_TYPE_PURPOSE%TYPE,
 p_dependent_sty_purpose IN okl_strm_type_b.STREAM_TYPE_PURPOSE%TYPE,
 x_return_status	 OUT NOCOPY VARCHAR2,
 x_dependent_sty_id 	 OUT NOCOPY okl_strm_type_b.ID%TYPE
)

IS

CURSOR cntrct_csr (l_khr_id NUMBER)IS
SELECT pdt.reporting_pdt_id, khr.start_date
FROM     okl_k_headers_full_v khr, okl_products pdt
WHERE khr.id = l_khr_id
AND   khr.pdt_id = pdt.id;

CURSOR dep_sty_csr (l_product_id NUMBER, l_contract_start_date DATE) IS
SELECT DEPENDENT_STY_ID
FROM   OKL_STRM_TMPT_LINES_UV STL
WHERE PRIMARY_YN = 'N'
AND STL.PDT_ID = l_product_id
AND    (STL.START_DATE <= l_contract_start_date)
AND   (STL.END_DATE >= l_contract_start_date OR STL.END_DATE IS NULL)
AND	   PRIMARY_STY_PURPOSE =   p_primary_sty_purpose
AND	   DEPENDENT_STY_PURPOSE =   p_dependent_sty_purpose;

  l_product_id 			  					NUMBER;
  l_contract_start_date 	DATE;
  l_dependetn_sty_id 			  					NUMBER;

-- Santonyr Bug 4056364

  l_dep_sty_purpose_meaning VARCHAR2(4000);

BEGIN

  x_return_status         := Okl_Api.G_RET_STS_SUCCESS;

  OPEN cntrct_csr (p_khr_id);
  FETCH cntrct_csr INTO l_product_id, l_contract_start_date;
  CLOSE cntrct_csr;

  IF (p_product_id IS NOT NULL) AND (l_contract_start_date IS NOT NULL) THEN

    OPEN dep_sty_csr (p_product_id, l_contract_start_date);
    FETCH dep_sty_csr INTO l_dependetn_sty_id;
      IF  dep_sty_csr%NOTFOUND THEN

            l_dep_sty_purpose_meaning := OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING
            			('OKL_STREAM_TYPE_PURPOSE', p_dependent_sty_purpose);
            OKL_API.SET_MESSAGE(p_app_name      => g_app_name,
                                p_msg_name      => 'OKL_NO_DEP_STY_FOUND',
                                p_token1        => 'PURPOSE',
                                p_token1_value  => l_dep_sty_purpose_meaning);
            RAISE Okl_Api.G_EXCEPTION_ERROR;
	 END IF;
     CLOSE dep_sty_csr;

  ELSE
	        Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_NO_PDT_FOUND');
            RAISE Okl_Api.G_EXCEPTION_ERROR;

  END IF;

  x_dependent_sty_id := l_dependetn_sty_id;

  EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
     IF cntrct_csr%ISOPEN THEN
	    CLOSE cntrct_csr;
	 END IF;
     IF dep_sty_csr%ISOPEN THEN
	    CLOSE dep_sty_csr;
	 END IF;
     x_return_status := Okl_Api.G_RET_STS_ERROR ;

  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
     IF cntrct_csr%ISOPEN THEN
	    CLOSE cntrct_csr;
	 END IF;
     IF dep_sty_csr%ISOPEN THEN
	    CLOSE dep_sty_csr;
	 END IF;
     x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN
     IF cntrct_csr%ISOPEN THEN
	    CLOSE cntrct_csr;
	 END IF;
     IF dep_sty_csr%ISOPEN THEN
	    CLOSE dep_sty_csr;
	 END IF;
     x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
END get_dependent_stream_type_rep;

-- Added for bug 6326479  - End

-- Evaluates whether a stream type is present in the stream generation
-- template for a contract
FUNCTION strm_tmpt_contains_strm_type
(
 p_khr_id  		 IN okl_k_headers_full_v.id%TYPE,
 p_sty_id        IN okl_strm_type_b.ID%TYPE
)
RETURN VARCHAR2
IS

CURSOR cntrct_csr (l_khr_id NUMBER)IS
SELECT pdt_id, start_date
FROM     okl_k_headers_full_v
WHERE id = l_khr_id;

CURSOR sty_csr (l_product_id NUMBER, l_contract_start_date DATE) IS
SELECT '1'
FROM   OKL_STRM_TMPT_FULL_UV STL
WHERE STL.PDT_ID = l_product_id
AND    (STL.START_DATE <= l_contract_start_date)
AND   (STL.END_DATE >= l_contract_start_date OR STL.END_DATE IS NULL)
AND	   STY_ID =   p_sty_id;

  l_product_id 			  	NUMBER;
  l_contract_start_date 	DATE;
  l_sty_id                  NUMBER;

BEGIN

  OPEN cntrct_csr (p_khr_id);
  FETCH cntrct_csr INTO l_product_id, l_contract_start_date;
  CLOSE cntrct_csr;

  IF (l_product_id IS NOT NULL) AND (l_contract_start_date IS NOT NULL) THEN
    OPEN sty_csr (l_product_id, l_contract_start_date);
    FETCH sty_csr INTO l_sty_id;
    IF  sty_csr%NOTFOUND THEN
      CLOSE sty_csr;
      RETURN 'N';
	ELSE
      CLOSE sty_csr;
	  RETURN 'Y';
	END IF;
  ELSE
      RETURN 'N';
  END IF;

  EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
     IF cntrct_csr%ISOPEN THEN
	    CLOSE cntrct_csr;
	 END IF;
  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
     IF cntrct_csr%ISOPEN THEN
	    CLOSE cntrct_csr;
	 END IF;
  WHEN OTHERS THEN
     IF cntrct_csr%ISOPEN THEN
	    CLOSE cntrct_csr;
	 END IF;
END strm_tmpt_contains_strm_type;


-- Gets the status of the stream generation request for external generator
PROCEDURE get_transaction_status
(
 p_transaction_number  IN okl_stream_interfaces.transaction_number%TYPE,
 x_transaction_status  OUT NOCOPY okl_stream_interfaces.sis_code%TYPE,
 x_logfile_name        OUT NOCOPY okl_stream_interfaces.log_file%TYPE,
 x_return_status       OUT NOCOPY VARCHAR2
)
IS
  l_transaction_status okl_stream_interfaces.sis_code%TYPE := null;
  l_logfile_name       okl_stream_interfaces.log_file%TYPE := null;

  CURSOR intf_status_csr(trx_number NUMBER)
  IS
    SELECT sis_code, log_file FROM okl_stream_interfaces
	WHERE transaction_number = trx_number;

BEGIN

  OPEN intf_status_csr(p_transaction_number);
  FETCH intf_status_csr INTO l_transaction_status, l_logfile_name;

  IF intf_status_csr%NOTFOUND THEN
	 Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                         p_msg_name     => 'OKL_TRX_NUM_NOT_FOUND');
     RAISE Okl_Api.G_EXCEPTION_ERROR;
  END IF;

  CLOSE intf_status_csr;

  x_transaction_status    := l_transaction_status;
  x_logfile_name          := l_logfile_name;
  x_return_status         := Okl_Api.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
     IF intf_status_csr%ISOPEN THEN
	    CLOSE intf_status_csr;
	 END IF;
     x_return_status := Okl_Api.G_RET_STS_ERROR ;
  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
     IF intf_status_csr%ISOPEN THEN
	    CLOSE intf_status_csr;
	 END IF;
     x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
     IF intf_status_csr%ISOPEN THEN
	    CLOSE intf_status_csr;
	 END IF;
     x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
END;


-- Added by Santonyr
--------------------------------------------------------------------------------
-- Start of Commnets
-- Procedure Name       : get_pricing_engine
-- Description          : Returns pricing engine for a contract based on the product
--                        stream template
-- Business Rules       :
-- Parameters           : P_khr_id,
-- Version              : 1.0
-- History              : santonyr 10-Dec-2004 - created
-- End of Commnets
--------------------------------------------------------------------------------

FUNCTION get_pricing_engine(p_khr_id IN okl_k_headers.id%TYPE)
RETURN VARCHAR2
IS

-- Cursor to fetch the pricing engine for a contract.

CURSOR prc_eng_csr IS
SELECT
   gts.pricing_engine
FROM
  okl_k_headers khr,
  okl_products_v pdt,
  okl_ae_tmpt_sets_v aes,
  OKL_ST_GEN_TMPT_SETS gts
WHERE
  khr.pdt_id = pdt.id AND
  pdt.aes_id = aes.id AND
  aes.gts_id = gts.id AND
  khr.id  = p_khr_id;

l_pricing_engine okl_st_gen_tmpt_sets.pricing_engine%TYPE;

BEGIN

OPEN prc_eng_csr;
FETCH prc_eng_csr INTO l_pricing_engine;
CLOSE prc_eng_csr;

RETURN l_pricing_engine;

EXCEPTION
  WHEN OTHERS THEN
    IF prc_eng_csr%ISOPEN THEN
      CLOSE prc_eng_csr;
    END IF;
    RETURN NULL;

END get_pricing_engine;

-- Added by Santonyr
--------------------------------------------------------------------------------
-- Start of Commnets
-- Procedure Name       : get_pricing_engine
-- Description          : Returns pricing engine for a contract based on the product
--                        stream template
-- Business Rules       :
-- Parameters           : p_khr_id,
-- Version              : 1.0
-- History              : santonyr 10-Dec-2004 - created
-- End of Commnets
--------------------------------------------------------------------------------

PROCEDURE get_pricing_engine
	(p_khr_id IN okl_k_headers.id%TYPE,
	x_pricing_engine OUT NOCOPY VARCHAR2,
	x_return_status OUT NOCOPY VARCHAR2)
IS

CURSOR prc_eng_csr IS
SELECT
   gts.name
FROM
  okl_k_headers khr,
  okl_products_v pdt,
  okl_ae_tmpt_sets_v aes,
  OKL_ST_GEN_TMPT_SETS gts
WHERE
  khr.pdt_id = pdt.id AND
  pdt.aes_id = aes.id AND
  aes.gts_id = gts.id AND
  khr.id  = p_khr_id;

l_pricing_engine okl_st_gen_tmpt_sets.pricing_engine%TYPE;
l_st_tmpt_name okl_st_gen_tmpt_sets.name%TYPE;

BEGIN
  x_return_status         := OKL_API.G_RET_STS_SUCCESS;

  -- Call get_pricing_engine to get the pricing engine

  l_pricing_engine := Okl_Streams_Util.get_pricing_engine(p_khr_id);

  -- Set the message if the pricing engine is NULL

  IF l_pricing_engine IS NULL THEN

     OPEN prc_eng_csr;
     FETCH prc_eng_csr INTO l_st_tmpt_name;
     CLOSE prc_eng_csr;

     Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                         p_msg_name     => 'OKL_NO_PRICING_ENGINE',
                         p_token1	=> 'STREAM_TEMPLATE',
                         p_token1_value => l_st_tmpt_name);

     RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  -- Return the pricing engine

  x_pricing_engine := l_pricing_engine;

EXCEPTION

  WHEN OKL_API.G_EXCEPTION_ERROR THEN
     IF prc_eng_csr%ISOPEN THEN
       CLOSE prc_eng_csr;
     END IF;
     x_return_status := OKL_API.G_RET_STS_ERROR ;

  WHEN OTHERS THEN
     IF prc_eng_csr%ISOPEN THEN
       CLOSE prc_eng_csr;
     END IF;
     x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END get_pricing_engine;

-- Bug 4196515 - Start of Changes
--------------------------------------------------------------------------------
-- Start of Commnets
-- Procedure Name       : round_streams_amount_esg
-- Description          : Returns PL/SQL table of record rounded amounts
--                        of OKL_STRM_ELEMENTS type during the External Stream
--                        Generation Process
-- Business Rules       : We sum the amounts given as I/P PL/SQL table first.
--                        And then we round the amounts using existing
--                        rounding rule and then sum them these up.
--                        If we find a difference between rounded amount
--                        and non-rounded amount then based on already existing
--                        rule we do adjustment to the first amount or
--                        last amount or the High value amount of the PL/SQL
--                        table of records.We then give the rounded values
--                        thru O/P PL/SQL table of records.
-- Parameters           : P_chr_id,
--                        p_selv_tbl of OKL_STRM_ELEMENTS type
--                        x_selv_tbl of OKL_STRM_ELEMENTS type,
--                        p_org_id,
--                        p_precision,
--                        p_currency_code,
--                        p_rounding_rule,
--                        p_apply_rnd_diff
-- End of Commnets
--------------------------------------------------------------------------------
-- The difference between the functions round_streams_amount and
-- round_streams_amount_esg is in the parameters being passed to the call.

-- Instead of obtaining the values of org_id, precision, currency_code, rounding_rule
-- apply_rounding_difference everytime the function is called by executing cursors,
-- these values are calculated and passed from Okl_Process_Streams_Pvt.process_stream_results

  FUNCTION round_streams_amount_esg(p_api_version    IN  NUMBER,
                                p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                x_msg_count      OUT NOCOPY NUMBER,
                                x_msg_data       OUT NOCOPY VARCHAR2,
                                p_chr_id         IN okc_k_headers_b.id%TYPE,
                                p_selv_tbl       IN okl_streams_pub.selv_tbl_type,
                                x_selv_tbl       OUT NOCOPY okl_streams_pub.selv_tbl_type,
                                p_org_id         IN okc_k_headers_b.authoring_org_id%TYPE,
                                p_precision      IN NUMBER,
                                p_currency_code  IN okc_k_headers_b.currency_code%TYPE,
                                p_rounding_rule  IN okl_sys_acct_opts.stm_rounding_rule%TYPE,
                                p_apply_rnd_diff IN okl_sys_acct_opts.stm_apply_rounding_difference%TYPE)
  RETURN VARCHAR2 IS
   l_api_name               CONSTANT VARCHAR2(30) := 'ROUND_STREAMS_AMOUNT';
    g_col_name_token         CONSTANT  VARCHAR2(200) := Okl_Api.G_COL_NAME_TOKEN;
    g_no_match_rec           CONSTANT VARCHAR2(30) := 'OKL_LLA_NO_MATCHING_RECORD';
    g_invalid_value          CONSTANT VARCHAR2(200) := 'OKL_INVALID_VALUE ';
    g_rnd_diff_lookup_type   CONSTANT fnd_lookups.lookup_type%TYPE := 'OKL_STRM_APPLY_ROUNDING_DIFF';
    g_first_lookup_code      CONSTANT fnd_lookups.lookup_code%TYPE := 'ADD_TO_FIRST';
    g_last_lookup_code       CONSTANT fnd_lookups.lookup_code%TYPE := 'ADD_TO_LAST';
    g_high_lookup_code       CONSTANT fnd_lookups.lookup_code%TYPE := 'ADD_TO_HIGH';
    x_return_status                   VARCHAR2(3)  := Okl_Api.G_RET_STS_SUCCESS;
    ln_grter_amt_ind                  NUMBER := 0;
    ln_grter_amt                      NUMBER := 0;
    ln_tot_no_rnd_amount              NUMBER := 0;
    ln_tot_rnd_amount                 NUMBER := 0;
    ln_rounded_amount                 NUMBER := 0;
    ln_rnd_diff_amount                NUMBER := 0;
    ln_diff_amount                    NUMBER := 0;
    ln_chr_id                         okc_k_headers_b.id%TYPE := p_chr_id;
    ln_org_id                         okc_k_headers_b.authoring_org_id%TYPE := p_org_id;
    lv_currency_code                  okc_k_headers_b.currency_code%TYPE := p_currency_code;
    lv_diff_lookup_code               fnd_lookups.lookup_code%TYPE := p_apply_rnd_diff;
    lv_rounding_rule                  fnd_lookups.lookup_code%TYPE := p_rounding_rule;
    g_stop_round_exp                  EXCEPTION;
    ln_precision1                     NUMBER := p_precision;
    g_rounding_error                  EXCEPTION;
    lv_return_status    VARCHAR2(3) := Okl_Api.G_RET_STS_SUCCESS;
    l_first_rec_index                 NUMBER := 0;
    l_last_rec_index                  NUMBER := 0;
    l_min_date                        DATE;
    l_max_date                        DATE;

      -- Get the precision for the amounts to Round
      -- Depending on the Currency code
      CURSOR get_precision(p_currency_code OKC_K_HEADERS_B.CURRENCY_CODE%TYPE) IS
      SELECT PRECISION
      FROM fnd_currencies_vl
      WHERE currency_code = p_currency_code
      AND enabled_flag = 'Y'
      AND NVL(start_date_active, SYSDATE) <= SYSDATE
      AND NVL(end_date_active, SYSDATE) >= SYSDATE;

    l_selv_tbl                        Okl_Streams_Pub.selv_tbl_type := p_selv_tbl;
    -- Get the Rule to Adjust the amount either
    -- top/bottom/high_value of the PL/SQL tbl record
    CURSOR get_rnd_diff_lookup(p_lookup_type  fnd_lookups.lookup_type%TYPE)
    IS
    SELECT b.stm_apply_rounding_difference
    FROM fnd_lookups a,
         OKL_SYS_ACCT_OPTS b
    WHERE a.lookup_type = p_lookup_type
    AND a.lookup_code = b.stm_apply_rounding_difference;
    -- get the currency_code and Authoring_org_id
    -- from okc_k_headers_b
    CURSOR get_org_id(p_chr_id  okc_k_headers_b.id%TYPE)
    IS
    SELECT authoring_org_id,
           currency_code
    FROM okc_k_headers_b
    WHERE id = p_chr_id;

    --Cursor to fetch the Stream Rounding Rule
    CURSOR get_rounding_rule IS
    SELECT stm_rounding_rule
    FROM OKL_SYS_ACCT_OPTS;


    -- Local Function to round the amount depending on the
    -- Currency code
    FUNCTION round_amount(p_amount        IN  NUMBER,
                          p_add_precision IN  NUMBER,
                          x_amount        OUT NOCOPY NUMBER,
                          p_currency_code IN okc_k_headers_b.currency_code%TYPE,
                          p_precision     IN  NUMBER,
                          p_rounding_rule IN  okl_sys_acct_opts.ael_rounding_rule%TYPE)
    RETURN VARCHAR2 AS
      lv_rounding_rule    okl_sys_acct_opts.ael_rounding_rule%TYPE := p_rounding_rule ;
      ln_precision        NUMBER := p_precision;
      ln_amount           NUMBER := p_amount;
      ln_rounded_amount   NUMBER := 0;
      ln_pos_dot          NUMBER;
      ln_to_add           NUMBER := 1;
      lv_return_status    VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;

    BEGIN
      IF ((lv_rounding_rule IS NOT NULL) AND (ln_precision IS NOT NULL)) THEN
         -- We now Processing the rounding depending
         -- on the rule we derived from the above cursor
         -- get rounding rule
         IF (lv_rounding_rule = 'UP') THEN
           ln_pos_dot := INSTR(TO_CHAR(ln_amount),'.') ;
           IF (ln_pos_dot > 0) AND
           (SUBSTR(ln_amount,ln_pos_dot+ln_precision+1 + p_add_precision,1) IS NOT NULL) THEN
              FOR i IN 1..ln_precision + p_add_precision LOOP
                ln_to_add := ln_to_add/10;
              END LOOP;
              ln_rounded_amount := ln_amount + ln_to_add;
           ELSE
              ln_rounded_amount := ln_amount;
           END IF;
           ln_rounded_amount := TRUNC(ln_rounded_amount,ln_precision + p_add_precision);
         ELSIF lv_rounding_rule = 'DOWN' THEN
           ln_rounded_amount := TRUNC(ln_amount, ln_precision + p_add_precision);
         ELSIF lv_rounding_rule = 'NEAREST' THEN
           ln_rounded_amount := ROUND(ln_amount, ln_precision + p_add_precision);
         END IF;
         x_amount := ln_rounded_amount;
         RETURN lv_return_status;
      ELSE
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        lv_return_status := OKL_API.G_RET_STS_ERROR;
        RETURN lv_return_status;
    END round_amount;
  BEGIN

    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := Okl_Api.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    IF l_selv_tbl.COUNT > 0 THEN
       --If the org_id or the currency code is not passed to the function , only
       --then is the cursor executed.

       IF (ln_org_id IS NULL) OR (lv_currency_code IS NULL) THEN
         OPEN  get_org_id(p_chr_id => ln_chr_id);
         FETCH get_org_id INTO ln_org_id,
                            lv_currency_code;
         IF get_org_id%NOTFOUND THEN
           OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => g_no_match_rec,
                            p_token1       => g_col_name_token,
                            p_token1_value => 'Contract id');
           RAISE g_stop_round_exp;
         END IF;
         CLOSE get_org_id;
       END IF;

       -- we need to set the context since the records in
       -- OKL_SYS_ACCT_OPTS table are stored with regards to the context
       x_return_status      := OKL_API.G_RET_STS_SUCCESS;

       --If the apply rounding diff rule is not passed to the function , only
       --then is the cursor executed.
       IF (lv_diff_lookup_code IS NULL) THEN
          -- IF we have diff btw rounding amounts
          -- now we decide by the below select stmt
          -- As to where we need to adjust the amount
          OPEN  get_rnd_diff_lookup(p_lookup_type => g_rnd_diff_lookup_type);
          FETCH get_rnd_diff_lookup INTO lv_diff_lookup_code;
          IF get_rnd_diff_lookup%NOTFOUND THEN
            OKL_API.set_message(p_app_name     => G_APP_NAME,
                                p_msg_name     => g_no_match_rec,
                                p_token1       => g_col_name_token,
                                p_token1_value => 'Rounding Diff Lookup');
            RAISE g_stop_round_exp;
          END IF;
          CLOSE get_rnd_diff_lookup;
       END IF;

       --If the rounding rule is not passed to the function , only
       --then is the cursor executed.
       IF (lv_rounding_rule IS NULL) THEN
          -- Get the Rule to Round the amount
          OPEN get_rounding_rule;
          FETCH get_rounding_rule INTO lv_rounding_rule;
          IF get_rounding_rule%NOTFOUND THEN
             OKL_API.set_message(p_app_name     => G_APP_NAME,
                                 p_msg_name     => g_no_match_rec,
                                 p_token1       => g_col_name_token,
                                 p_token1_value => 'Rounding Rule');
             RAISE g_rounding_error;
          END IF;
          CLOSE get_rounding_rule;
        END IF;
      -- Modified by kthiruva on 02-Dec-2004
      -- Bug 4048047 - Start of Changes
      -- If the Apply Rounding Diff is ADD_TO_FIRST or ADD_TO_LAST then then the first and the last
      -- stream element records need to be determined.The first and last stream element record for
      -- a particular stream header is identified by checking for the min and max stream element date.

      IF lv_diff_lookup_code = g_first_lookup_code THEN
         l_first_rec_index := l_selv_tbl.FIRST;
         l_min_date        := l_selv_tbl(l_selv_tbl.FIRST).stream_element_date;
      ELSIF lv_diff_lookup_code = g_last_lookup_Code THEN
         l_last_rec_index  := l_selv_tbl.LAST;
         l_max_date        := l_Selv_tbl(l_selv_tbl.LAST).stream_element_date;
      END IF;
      -- Bug 4048047 - End of Changes

      -- Need to handle the -ve amount seprately
      -- since 0 is allways greater than -ve amounts
      IF lv_diff_lookup_code = g_high_lookup_code THEN
        IF SIGN(l_selv_tbl(l_selv_tbl.FIRST).amount) = -1 THEN
          ln_grter_amt :=  l_selv_tbl(l_selv_tbl.FIRST).amount;
        END IF;
      END IF;

      -- Now we scan the Stream element PL/SQL table of records
      -- Sum up all the amounts
      FOR i IN l_selv_tbl.FIRST..l_selv_tbl.LAST LOOP
        ln_tot_no_rnd_amount := ln_tot_no_rnd_amount + l_selv_tbl(i).amount;
        IF l_selv_tbl(i).amount > ln_grter_amt THEN
          ln_grter_amt := l_selv_tbl(i).amount;
          ln_grter_amt_ind := i;
        END IF;
        -- Added by kthiruva on 02-Dec-2004
        -- Bug 4048047 - Start of Changes
        -- Check to see if there is a stream element with a stream_element_date less than l_min_date.
        -- If so, the l_first_rec_index is reset.
        IF trunc(l_selv_tbl(i).stream_element_date) < trunc(l_min_date) THEN
           l_min_date        := l_selv_tbl(i).stream_element_date;
           l_first_rec_index := i;
        END IF;
        -- Check to see if there is a stream element with a stream_element_date greater than l_max_date.
        -- If so, the l_last_rec_index is reset.
        IF trunc(l_selv_tbl(i).stream_element_date) > trunc(l_max_date) THEN
           l_max_date       := l_selv_tbl(i).stream_element_date;
           l_last_rec_index := i;
        END IF;
        -- Bug 4048047 - End of Changes
      END LOOP;

      --If the precision is not passed to the function , only
      --then is the cursor executed.
      IF (ln_precision1 IS NULL) THEN
        -- Get the precision for the amounts to Round
        -- Depending on the Currency code
        OPEN get_precision(p_currency_code => lv_currency_code);
        FETCH get_precision INTO ln_precision1;
        IF get_precision%NOTFOUND THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => g_no_match_rec,
                            p_token1       => g_col_name_token,
                            p_token1_value => 'Currency Code');
          RAISE g_rounding_error;
        END IF;
        CLOSE get_precision;
      END IF;


--sgorantl(bug#3797982) start change
      ln_tot_no_rnd_amount := ROUND(ln_tot_no_rnd_amount,ln_precision1);
--sgorantl(bug#3797982) end change

      -- If the first value is 0 and ln_grter_amt = 0
      -- then we return the first record for adjustment
      IF lv_diff_lookup_code = g_high_lookup_code THEN
        IF ln_grter_amt_ind = 0 THEN
          ln_grter_amt := l_selv_tbl(l_selv_tbl.FIRST).amount;
          ln_grter_amt_ind := l_selv_tbl.FIRST;
        END IF;
      END IF;
      -- Now we scan the Stream element PL/SQL table of records
      -- Sum up all the amounts after rounding depending on currency_code
      FOR i IN l_selv_tbl.FIRST..l_selv_tbl.LAST LOOP
        x_return_status := round_amount(p_currency_code => lv_currency_code,
                                        p_add_precision => 0,
                                        p_amount        => l_selv_tbl(i).amount,
                                        x_amount        => ln_rounded_amount,
                                        p_precision     => ln_precision1,
                                        p_rounding_rule => lv_rounding_rule);
        IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
          EXIT WHEN (x_return_status <> OKL_API.G_RET_STS_SUCCESS);
        END IF;
        ln_tot_rnd_amount := ln_tot_rnd_amount + ln_rounded_amount;
        -- We re-populate the rounded amount into the PL/SQL table of records
        -- So that we can give the same as output if there is diff
        -- btw ln_tot_no_rnd_amount and ln_tot_rnd_amount
        l_selv_tbl(i).amount := ln_rounded_amount;
      END LOOP;
      IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
        RAISE g_stop_round_exp;
      END IF;
      -- Now we will see the diff btw ln_tot_no_rnd_amount and ln_tot_rnd_amount
      -- IF there is diff then as done below
      IF ln_tot_no_rnd_amount <> ln_tot_rnd_amount THEN
        -- If the diff correction rule is First then

        IF lv_diff_lookup_code = g_first_lookup_code THEN
          -- If the Diff Amount is +ve then we add to the first record of
          -- pl/sql record of the table
          ln_diff_amount := ln_tot_no_rnd_amount - ln_tot_rnd_amount;
          -- Since the pl/sql table of records come in as not rounded
          -- and in the above we round the pl/sql table of records
          -- and since we need to do the corrections only on the rounded amont
          -- hence we need to round the ln_diff_amount variable also.
          x_return_status := round_amount(p_currency_code => lv_currency_code,
                                          p_add_precision => 0,
                                          p_amount        => ln_diff_amount,
                                          x_amount        => ln_rnd_diff_amount,
                                          p_precision     => ln_precision1,
                                          p_rounding_rule => lv_rounding_rule);
          IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
            RAISE g_stop_round_exp;
          END IF;
          IF SIGN(ln_rnd_diff_amount) = 1 THEN
            -- Modified by kthiruva on 02-Dec-2004
            -- Bug 4048047 - Start of Changes
            l_selv_tbl(l_first_rec_index).amount := l_selv_tbl(l_first_rec_index).amount + ln_rnd_diff_amount;
            --Bug 4048047 - End of Changes
          -- If the Diff Amount is -ve then we substract from the first record of
          -- pl/sql record of the table
          ELSIF SIGN(ln_rnd_diff_amount) = -1 THEN
            ln_diff_amount := ln_tot_rnd_amount- ln_tot_no_rnd_amount ;
            -- Since the pl/sql table of records come in as not rounded
            -- and in the above we round the pl/sql table of records
            -- and since we need to do the corrections only on the rounded amont
            -- hence we need to round the ln_diff_amount variable also.
            x_return_status := round_amount(p_currency_code => lv_currency_code,
                                            p_add_precision => 0,
                                            p_amount        => ln_diff_amount,
                                            x_amount        => ln_rnd_diff_amount,
                                            p_precision     => ln_precision1,
                                            p_rounding_rule => lv_rounding_rule);
            IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
              RAISE g_stop_round_exp;
            END IF;
            -- Modified by kthiruva on 02-Dec-2004
            -- Bug 4048047 - Start of Changes
            l_selv_tbl(l_first_rec_index).amount := l_selv_tbl(l_first_rec_index).amount - (ln_rnd_diff_amount);
            -- Bug 4048047 - End Of Changes
          END IF;
        -- If the diff correction rule is Last then
        ELSIF lv_diff_lookup_code = g_last_lookup_code THEN
          -- If the Diff Amount is +ve then we add to the last record of
          -- pl/sql record of the table
          ln_diff_amount := ln_tot_no_rnd_amount - ln_tot_rnd_amount;
          -- Since the pl/sql table of records come in as not rounded
          -- and in the above we round the pl/sql table of records
          -- and since we need to do the corrections only on the rounded amont
          -- hence we need to round the ln_diff_amount variable also.
          x_return_status := round_amount(p_currency_code => lv_currency_code,
                                          p_add_precision => 0,
                                          p_amount        => ln_diff_amount,
                                          x_amount        => ln_rnd_diff_amount,
                                          p_precision     => ln_precision1,
                                          p_rounding_rule => lv_rounding_rule);
          IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
            RAISE g_stop_round_exp;
          END IF;
          IF SIGN(ln_rnd_diff_amount) = 1 THEN
            -- Modified by kthiruva on 02-Dec-2004
            -- Bug 4048047 - Start of Changes
            l_selv_tbl(l_last_rec_index).amount := l_selv_tbl(l_last_rec_index).amount + (ln_rnd_diff_amount);
            -- Bug 4048047 - End of Changes
          -- If the Diff Amount is -ve then we substract from the last record of
          -- pl/sql record of the table
          ELSIF SIGN(ln_rnd_diff_amount) = -1 THEN
            ln_diff_amount := ln_tot_rnd_amount- ln_tot_no_rnd_amount ;
            -- Since the pl/sql table of records come in as not rounded
            -- and in the above we round the pl/sql table of records
            -- and since we need to do the corrections only on the rounded amont
            -- hence we need to round the ln_diff_amount variable also.
            x_return_status := round_amount(p_currency_code => lv_currency_code,
                                            p_add_precision => 0,
                                            p_amount        => ln_diff_amount,
                                            x_amount        => ln_rnd_diff_amount,
                                            p_precision     => ln_precision1,
                                            p_rounding_rule => lv_rounding_rule);
            IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
              RAISE g_stop_round_exp;
            END IF;
            -- Modified by kthiruva on 02-Dec-2004
            -- Bug 4048047 - Start of Changes
            --Modified by kthiruva for Bug 4730902 on 22-Nov-2005.
            --The amount needs to be subtracted when the diff is negative
            l_selv_tbl(l_last_rec_index).amount := l_selv_tbl(l_last_rec_index).amount - (ln_rnd_diff_amount);
            -- Bug 4048047 - End of Changes
          END IF;
        -- If the diff correction rule is High Amount then
        ELSIF lv_diff_lookup_code = g_high_lookup_code  THEN
          ln_diff_amount := ln_tot_no_rnd_amount - ln_tot_rnd_amount;
          -- Since the pl/sql table of records come in as not rounded
          -- and in the above we round the pl/sql table of records
          -- and since we need to do the corrections only on the rounded amont
          -- hence we need to round the ln_diff_amount variable also.
          x_return_status := round_amount(p_currency_code => lv_currency_code,
                                          p_add_precision => 0,
                                          p_amount        => ln_diff_amount,
                                          x_amount        => ln_rnd_diff_amount,
                                          p_precision     => ln_precision1,
                                          p_rounding_rule => lv_rounding_rule);
          IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
            RAISE g_stop_round_exp;
          END IF;
          -- If the Diff Amount is +ve then we add to the High amount record of
          -- pl/sql record of the table
          IF SIGN(ln_rnd_diff_amount) = 1 THEN
            l_selv_tbl(ln_grter_amt_ind).amount := l_selv_tbl(ln_grter_amt_ind).amount + (ln_rnd_diff_amount);
          -- If the Diff Amount is -ve then we substract from the High amount record of
          -- pl/sql record of the table
          ELSIF SIGN(ln_rnd_diff_amount) = -1 THEN
            ln_diff_amount := ln_tot_rnd_amount- ln_tot_no_rnd_amount ;
            -- Since the pl/sql table of records come in as not rounded
            -- and in the above we round the pl/sql table of records
            -- and since we need to do the corrections only on the rounded amont
            -- hence we need to round the ln_diff_amount variable also.
            x_return_status := round_amount(p_currency_code => lv_currency_code,
                                            p_add_precision => 0,
                                            p_amount        => ln_diff_amount,
                                            x_amount        => ln_rnd_diff_amount,
                                            p_precision     => ln_precision1,
                                            p_rounding_rule => lv_rounding_rule);

            IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
              RAISE g_stop_round_exp;
            END IF;
            l_selv_tbl(ln_grter_amt_ind).amount := l_selv_tbl(ln_grter_amt_ind).amount - (ln_rnd_diff_amount);
          END IF;
        END IF;
        -- There is diff so we set the o/p record with modified record derived above
        x_selv_tbl := l_selv_tbl;
      ELSIF ln_tot_no_rnd_amount = ln_tot_rnd_amount THEN
        -- There is no diff so we set the i/p record back o/p record
        --Modified by dpsingh on 02-Feb-2006.          x_selv_tbl := p_selv_tbl;
         --Even when there is no rounding diff, the rounded table l_selv_tbl should only be returned
         --The unrounded table is being returned incorrectly
         --Bug 4559800(H) - Start of Changes
         x_selv_tbl := l_selv_tbl;
         --Bug 4559800(H) - End of Changes
      END IF;
    ELSE
      Okl_Api.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_INVALID_VALUE,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'p_selv_tbl');
      RAISE g_stop_round_exp;
    END IF;

    Okl_Api.END_ACTIVITY (x_msg_count,
                          x_msg_data );
    RETURN x_return_status;
  EXCEPTION
     WHEN g_rounding_error THEN
        IF get_precision%ISOPEN THEN
          CLOSE get_precision;
        END IF;
        lv_return_status := Okl_Api.G_RET_STS_ERROR;
        RETURN lv_return_status;
    WHEN g_stop_round_exp THEN
      IF get_rnd_diff_lookup%ISOPEN THEN
        CLOSE get_rnd_diff_lookup;
      END IF;
      IF get_org_id%ISOPEN THEN
        CLOSE get_org_id;
      END IF;
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OKL_API.G_RET_STS_ERROR',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
      RETURN x_return_status;
    WHEN OTHERS THEN
      IF get_rnd_diff_lookup%ISOPEN THEN
        CLOSE get_rnd_diff_lookup;
      END IF;
      IF get_org_id%ISOPEN THEN
        CLOSE get_org_id;
      END IF;
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS(
                                l_api_name,
                                G_PKG_NAME,
                                'OTHERS',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');
      RETURN x_return_status;
  END round_streams_amount_esg;
  --Bug 4196515-End of Changes

  -- Added by RGOOTY: Start
  PROCEDURE get_acc_options(    p_khr_id         IN  okc_k_headers_b.ID%TYPE,
                                x_org_id         OUT NOCOPY okc_k_headers_b.authoring_org_id%TYPE,
                                x_precision      OUT NOCOPY NUMBER,
                                x_currency_code  OUT NOCOPY okc_k_headers_b.currency_code%TYPE,
                                x_rounding_rule  OUT NOCOPY okl_sys_acct_opts.stm_rounding_rule%TYPE,
                                x_apply_rnd_diff OUT NOCOPY okl_sys_acct_opts.stm_apply_rounding_difference%TYPE,
                                x_return_status  OUT NOCOPY VARCHAR2 ) IS

  CURSOR get_org_id(p_chr_id  okc_k_headers_b.id%TYPE)
  IS
    SELECT authoring_org_id,
           currency_code
    FROM okc_k_headers_b
    WHERE id = p_chr_id;

  CURSOR get_precision(p_currency_code OKC_K_HEADERS_B.CURRENCY_CODE%TYPE)
  IS
      SELECT PRECISION
      FROM fnd_currencies_vl
      WHERE currency_code = p_currency_code
        AND enabled_flag = 'Y'
        AND NVL(start_date_active, SYSDATE) <= SYSDATE
        AND NVL(end_date_active, SYSDATE) >= SYSDATE;

  CURSOR get_rounding_rule
  IS
      SELECT stm_rounding_rule
      FROM OKL_SYS_ACCT_OPTS;

  CURSOR get_rnd_diff_lookup(p_lookup_type  fnd_lookups.lookup_type%TYPE)
  IS
    SELECT b.stm_apply_rounding_difference
    FROM fnd_lookups a,
         OKL_SYS_ACCT_OPTS b
    WHERE a.lookup_type = p_lookup_type
    AND a.lookup_code = b.stm_apply_rounding_difference;

  l_org_id              OKC_K_HEADERS_B.AUTHORING_ORG_ID%TYPE;
  l_currency_code       okc_k_headers_b.currency_code%type;
  l_diff_lookup_code    fnd_lookups.lookup_code%type;
  l_precision           number;
  l_rounding_rule       okl_sys_acct_opts.ael_rounding_rule%type;

  l_return_status       VARCHAR2(3)  := Okl_Api.G_RET_STS_SUCCESS;

  G_NO_MATCH_REC           CONSTANT VARCHAR2(30) := 'OKL_LLA_NO_MATCHING_RECORD';
  G_INVALID_VALUE          CONSTANT VARCHAR2(200) := 'OKL_INVALID_VALUE ';
  G_RND_DIFF_LOOKUP_TYPE   CONSTANT FND_LOOKUPS.LOOKUP_TYPE%TYPE := 'OKL_STRM_APPLY_ROUNDING_DIFF';
  G_COL_NAME_TOKEN         CONSTANT  VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;

  BEGIN
    -- Get the Org Id, Currency Code
    OPEN  get_org_id(p_chr_id => p_khr_id);
    FETCH get_org_id INTO l_org_id,l_currency_code;
    IF get_org_id%NOTFOUND THEN
        OKL_API.set_message(p_app_name     => G_APP_NAME,
                                    p_msg_name     => G_NO_MATCH_REC,
                                    p_token1       => G_COL_NAME_TOKEN,
                                    p_token1_value => 'Contract id');
        RAISE G_EXCEPTION_ERROR;
    END IF;
    CLOSE get_org_id;

    -- Get Rounding Difference Lookup
    OPEN  get_rnd_diff_lookup(p_lookup_type => G_RND_DIFF_LOOKUP_TYPE);
    FETCH get_rnd_diff_lookup INTO L_diff_lookup_code;
    IF get_rnd_diff_lookup%NOTFOUND THEN
        OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_NO_MATCH_REC,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'Rounding Diff Lookup');
        RAISE G_EXCEPTION_ERROR;
    END IF;
    CLOSE get_rnd_diff_lookup;

    -- Get the Precision
    OPEN get_precision(p_currency_code => l_currency_code);
    FETCH get_precision INTO l_precision;
    IF get_precision%NOTFOUND THEN
        OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_NO_MATCH_REC,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'Currency Code');
        RAISE G_EXCEPTION_ERROR;
    END IF;
    CLOSE get_precision;
    -- Get the Rounding Rule
    OPEN get_rounding_rule;
    FETCH get_rounding_rule INTO l_rounding_rule;
    IF get_rounding_rule%NOTFOUND THEN
        OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_NO_MATCH_REC,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'Rounding Rule');
        RAISE G_EXCEPTION_ERROR;
    END IF;
    CLOSE get_rounding_rule;

    x_org_id              := l_org_id;
    x_currency_code       := l_currency_code;
    x_apply_rnd_diff      := l_diff_lookup_code;
    x_precision           := l_precision;
    x_rounding_rule       := l_rounding_rule;
    x_return_status       := l_return_status;

  EXCEPTION
      WHEN G_EXCEPTION_ERROR THEN
         IF get_org_id%ISOPEN THEN
    	    CLOSE get_org_id;
    	 END IF;
         IF get_precision%ISOPEN THEN
    	    CLOSE get_precision;
    	 END IF;
         IF get_rounding_rule%ISOPEN THEN
    	    CLOSE get_rounding_rule;
    	 END IF;
         IF get_rnd_diff_lookup%ISOPEN THEN
    	    CLOSE get_rnd_diff_lookup;
    	 END IF;
         x_return_status := Okl_Api.G_RET_STS_ERROR ;

      WHEN OTHERS THEN
         IF get_org_id%ISOPEN THEN
    	    CLOSE get_org_id;
    	 END IF;
         IF get_precision%ISOPEN THEN
    	    CLOSE get_precision;
    	 END IF;
         IF get_rounding_rule%ISOPEN THEN
    	    CLOSE get_rounding_rule;
    	 END IF;
         IF get_rnd_diff_lookup%ISOPEN THEN
    	    CLOSE get_rnd_diff_lookup;
    	 END IF;
         x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
  END get_acc_options;

  -- Added by RGOOTY: End

-- Added by RGOOTY: Start
  --Modified bu kthiruva on 30-May-2005. The OUT param was made NOCOPY
  --Bug 4374085 - Start of Changes
  PROCEDURE accumulate_strm_headers(
    p_stmv_rec       IN            Okl_Streams_Pub.stmv_rec_type,
    x_full_stmv_tbl  IN OUT NOCOPY Okl_Streams_Pub.stmv_tbl_type,
    x_return_status  OUT NOCOPY    VARCHAR2)
  --Bug 4374085 - End of Change
 AS
    stmv_count        NUMBER;
    l_return_status   VARCHAR2(1);
  BEGIN
    -- Intialize the return status
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    stmv_count := x_full_stmv_tbl.count;
    IF ( stmv_count > 0)
    THEN
      -- Increment the current Index
      stmv_count := x_full_stmv_tbl.LAST + 1;
    ELSE
      stmv_count  := 1;
    END IF;
    --  Append it to the x_full_stmv_tbl
    x_full_stmv_tbl(stmv_count) := p_stmv_rec;

    -- Return the status
    x_return_Status := l_return_status;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR
    THEN
      x_return_status := G_RET_STS_ERROR;
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR
    THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS
    THEN
      OKL_API.SET_MESSAGE (
        p_app_name     => G_APP_NAME,
        p_msg_name     => 'OKL_DB_ERROR',
        p_token1       => 'PROG_NAME',
        p_token1_value => 'accumulate_strm_headers',
        p_token2       => G_SQLCODE_TOKEN,
        p_token2_value => sqlcode,
        p_token3       => G_SQLERRM_TOKEN,
        p_token3_value => sqlerrm);
      x_return_status := G_RET_STS_UNEXP_ERROR;
  END accumulate_strm_headers;

  --Modified bu kthiruva on 30-May-2005. The OUT param was made NOCOPY
  --Bug 4374085 - Start of Changes
  PROCEDURE accumulate_strm_elements(
    p_stm_index_no   IN            NUMBER,
    p_selv_tbl       IN            okl_streams_pub.selv_tbl_type,
    x_full_selv_tbl  IN OUT NOCOPY okl_streams_pub.selv_tbl_type,
    x_return_status  OUT NOCOPY    VARCHAR2)
  --Bug 4374085 - End of Changes
  AS
    selv_count        NUMBER;
    full_selv_count   NUMBER;
    i                 NUMBER; -- Index to loop through the Stream Elements table p_selv_tbl
    l_return_status   VARCHAR2(1);
  BEGIN
    -- Intialize the return status
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    full_selv_count := x_full_selv_tbl.count;
    IF (full_selv_count > 0)
    THEN
      selv_count := x_full_selv_tbl.LAST + 1;
    ELSE
      selv_count  := 1;
    END IF;
    -- Loop through the Stream Elements table and
    --  append it to the x_full_Selv_tbl
    FOR i in p_selv_tbl.FIRST .. p_selv_tbl.LAST
    LOOP
      IF p_selv_tbl.EXISTS(i)
      THEN
        x_full_selv_tbl(selv_count) := p_selv_tbl(i);
        -- Store the Parent Index number per each Stream Element Level
        IF p_stm_index_no IS NOT NULL
        THEN
          x_full_selv_tbl(selv_count).parent_index := p_stm_index_no;
        END IF;
        selv_count := selv_count + 1;
      END IF;
    END LOOP;
    x_return_Status := l_return_status;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR
    THEN
      x_return_status := G_RET_STS_ERROR;
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR
    THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS
    THEN
      OKL_API.SET_MESSAGE (
        p_app_name     => G_APP_NAME,
        p_msg_name     => 'OKL_DB_ERROR',
        p_token1       => 'PROG_NAME',
        p_token1_value => 'accumulate_strm_elements',
        p_token2       => G_SQLCODE_TOKEN,
        p_token2_value => sqlcode,
        p_token3       => G_SQLERRM_TOKEN,
        p_token3_value => sqlerrm);
      x_return_status := G_RET_STS_UNEXP_ERROR;
  END accumulate_strm_elements;
  -- Added by RGOOTY: End

  -- Added by kthiruva on 10-Oct-2005
  -- Bug 4664698 - Start of changes
  --------------------------------------------------------------------------------
  -- Start of Commnets
  -- Procedure Name       : get_line_id
  -- Description          : Fetches the contract line id from the stream interface
  --                        tables during the inbound processing
  --
  -- Business Rules       : Returns kle_id
  -- Parameters           : p_trx_number    - Transaction number of the pricing
  --                                          request
  --                        p_index_number  - The index number which uniquely
  --                                          defines every asset line
  -- Returns                x_kle_id        - Id of the asset
  --                        x_return_status - Return Status of the API
  -- Version              : kthiruva 1.0 Created
  -- End of Commnets
  --------------------------------------------------------------------------------
  PROCEDURE get_line_id(
    p_trx_number     IN         okl_stream_interfaces.TRANSACTION_NUMBER%TYPE,
    p_index_number   IN         okl_sif_ret_levels.INDEX_NUMBER%TYPE,
    x_kle_id         OUT NOCOPY NUMBER,
    x_return_status  OUT NOCOPY VARCHAR2)
  AS
   --Curosor to fetch the line_id from the stream interface tables
   CURSOR kle_id_csr(p_trx_number IN NUMBER,
                     p_index_number IN NUMBER)
   IS
   SELECT    SILB.KLE_ID
   FROM OKL_SIF_RET_LEVELS SRLB,
        OKL_SIF_RETS SIRB,
        OKL_STREAM_INTERFACES SIFB,
        OKL_SIF_LINES SILB
   WHERE SIFB.TRANSACTION_NUMBER = p_trx_number
   AND SIRB.TRANSACTION_NUMBER = SIFB.TRANSACTION_NUMBER
   AND SILB.SIF_ID = SIFB.ID
   AND SRLB.SIR_ID = SIRB.ID
   AND SRLB.INDEX_NUMBER = SILB.INDEX_NUMBER
   AND SRLB.INDEX_NUMBER = p_index_number;

   l_kle_id           NUMBER;
   g_no_match_rec           CONSTANT VARCHAR2(30) := 'OKL_LLA_NO_MATCHING_RECORD';
   g_col_name_token         CONSTANT  VARCHAR2(200) := Okl_Api.G_COL_NAME_TOKEN;


  BEGIN
    -- Intialize the return status
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    OPEN kle_id_csr(p_trx_number   => p_trx_number,
                    p_index_number => p_index_number);

    FETCH kle_id_csr INTO l_kle_id;
    IF kle_id_csr%NOTFOUND THEN
        OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_NO_MATCH_REC,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'Contract Line Id');
        RAISE G_EXCEPTION_ERROR;
    END IF;
    CLOSE kle_id_csr;
    --Assigning the line_id fetched to the return parameter
    x_kle_id := l_kle_id;
  EXCEPTION
   WHEN Okl_Api.G_EXCEPTION_ERROR THEN
     IF kle_id_csr%ISOPEN THEN
	    CLOSE kle_id_csr;
	 END IF;
     x_return_status := Okl_Api.G_RET_STS_ERROR ;
   WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
     IF kle_id_csr%ISOPEN THEN
	    CLOSE kle_id_csr;
	 END IF;
     x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
     IF kle_id_csr%ISOPEN THEN
	    CLOSE kle_id_csr;
	 END IF;
     x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
  END get_line_id;
  -- Bug 4664698 - End of Changes

procedure get_k_trx_state(p_trx_id IN number,
						  x_rebook_type OUT NOCOPY VARCHAR2,
						  x_rebook_date OUT NOCOPY DATE,
						  x_query_trx_state OUT NOCOPY VARCHAR2,
                          x_trx_state OUT NOCOPY CLOB) IS

    CURSOR get_orig_contract_csr( p_khr_id    IN NUMBER)
    IS
    SELECT rbk_chr.contract_number       rbk_contract_number,
           rbk_chr.orig_system_id1       original_chr_id,
           trx.rbr_code                  rbk_reason_code,
           trx.date_transaction_occurred revision_date,
           'ONLINE_REBOOK'               rebook_type
           ,rbk_chr.start_date           rbk_chr_start_date
           ,orig_chr.start_date          orig_chr_start_date
      FROM okc_k_headers_all_b   rbk_chr,
           okc_k_headers_all_b   orig_chr,
           okl_trx_contracts_all trx
     WHERE rbk_chr.id = p_khr_id
       AND rbk_chr.orig_system_source_code = 'OKL_REBOOK'
       AND trx.khr_id_new = rbk_chr.id
       AND trx.tsu_code = 'ENTERED'
       AND trx.tcn_type = 'TRBK'
       AND rbk_chr.orig_system_id1 = orig_chr.id
    UNION
    SELECT orig_chr.contract_number       rbk_contract_number,
           orig_chr.id                    original_chr_id,
           trx.rbr_code                   rbk_reason_code,
           trx.date_transaction_occurred  revision_date,
           'MASS_REBOOK'                  rebook_type
           ,orig_chr.start_date           rbk_chr_start_date
           ,orig_chr.start_date           orig_chr_start_date
      FROM okc_k_headers_all_b orig_chr,
           okl_trx_contracts_all trx
     WHERE  orig_chr.id    =  p_khr_id
      AND  trx.khr_id     =  orig_chr.id
      AND  trx.tsu_code   = 'ENTERED'
      AND  trx.tcn_type   = 'TRBK'
      AND  EXISTS
           (
            SELECT '1'
              FROM okl_rbk_selected_contract rbk_chr
             WHERE rbk_chr.khr_id = orig_chr.id
               AND rbk_chr.status <> 'PROCESSED'
            );
  l_contract_number VARCHAR2(120);
  l_contract_id     number;
  l_rbk_reason_code varchar2(30);
  l_revision_date    date;
  l_rebook_type     varchar2(15);
  l_purpose_code    varchar2(15);

  cursor get_clob(p_contract_id  IN NUMBER,
                  p_purpose_code IN VARCHAR2) IS
  select a.transaction_state
    from okl_stream_trx_data a,
	     okl_stream_interfaces b
   where a.orig_khr_id = p_contract_id
     and a.last_trx_state = 'Y'
	 and a.transaction_number = b.transaction_number
	 and nvl(b.purpose_code, 'PRIMARY') = p_purpose_code;

  cursor get_trx_contract(p_trx_id IN NUMBER) IS
  select khr_id, nvl(purpose_code, 'PRIMARY') purpose_code
    from okl_stream_interfaces
   where transaction_number = p_trx_id;

  cursor is_erd_enabled(p_trx_number IN NUMBER ) IS
  select nvl(sao.amort_inc_adj_rev_dt_yn, 'N') erd
    from okl_sys_acct_opts_all sao
        ,okl_stream_interfaces osi
        ,okc_k_headers_all_b   chr
    Where sao.org_id = chr.authoring_org_id
      and chr.id = osi.khr_id
      and osi.transaction_number = p_trx_number;
  -- Modified for the bug: 8870387

  l_copy_contract_id   number;
  l_erd_enabled        varchar2(1);
  l_orig_khr_start_date      DATE;
  l_rbk_khr_start_date       DATE;

begin

	 -- find if the prospective rebook feature is enabled for the OU.
	 open is_erd_enabled(p_trx_number => p_trx_id); -- Modified for bug 8870387
	 fetch is_erd_enabled into l_erd_enabled;
	 close is_erd_enabled;

     x_rebook_type := 'None';

	 -- if prospective rebook is enabled, then do the rest.
	 if l_erd_enabled = 'Y' then

       x_rebook_type := 'Prospective';
	   x_query_trx_state   := 'Y';

	   -- based on the transaction number passed, get the contract_id
	   -- and the context, whether primary or reporting
	   open get_trx_contract(p_trx_id);
	   fetch get_trx_contract into l_copy_contract_id, l_purpose_code;
	   close get_trx_contract;

	   -- for the copy_contract_id, get the original contract_id, in case of a online rebook
       open get_orig_contract_csr(l_copy_contract_id);
       fetch get_orig_contract_csr into l_contract_number, l_contract_id,
	                               l_rbk_reason_code, l_revision_date,
								   l_rebook_type,l_rbk_khr_start_date,l_orig_khr_start_date;

       close get_orig_contract_csr;

	   x_rebook_date := l_revision_date;

	   -- For normal booking and transactions like Splt Asset, the
	   -- rebook type tag should be populated with a value of 'None'.
	   -- Value should otherwise be 'Prospective', if the feature is enabled.
	   if l_rebook_type not in ('MASS_REBOOK', 'ONLINE_REBOOK') OR
	      l_rebook_type is NULL
	   then
         x_rebook_type := 'None';
	   end if;

       -- Case: During Online Revision, Contract Start Date has been Changed
       --       Hence, consider this as a Retrospective Case only
       IF l_orig_khr_start_date <> l_rbk_khr_start_date
       THEN
         x_rebook_type := 'None';
         x_rebook_date := NULL;
       END IF;

       -- Optimizing the Code to fetch the clob only if required !
       IF x_rebook_type <> 'None'
       THEN
         -- for the original contract_id, return the transaction state
         open get_clob(l_contract_id, l_purpose_code);
         fetch get_clob into x_trx_state;
         close get_clob;
       END IF;

	   -- Override of rebook_type tag to 'None' is done in case a mass rebook
	   -- was initiated before 'Effective Dated Rebook' is enabled, and failed.
	   -- If the feature is enabled at this time, the mass rebook transaction
	   -- should complete as a retrospective one.
	   if x_trx_state is null and l_rebook_type = 'MASS_REBOOK' then
	     x_rebook_type := 'None';
	   end if;
     end if;

exception
  when others then
    raise;
end get_k_trx_state;

-------------------------
procedure update_trx_state(p_khr_id in number,
                           p_context in varchar2) IS

l_trx_number	number;

cursor get_prim_trx(p_khr_id number) IS
select max(std.transaction_number)
  from okl_stream_trx_data std, okl_stream_interfaces osi
 where std.orig_khr_id = p_khr_id
   and std.transaction_number = osi.transaction_number
   and osi.purpose_code is NULL;

cursor get_rep_trx(p_khr_id number) IS
select max(std.transaction_number)
  from okl_stream_trx_data std, okl_stream_interfaces osi
 where std.orig_khr_id = p_khr_id
   and std.transaction_number = osi.transaction_number
   and osi.purpose_code is NOT NULL;

cursor is_prb_enabled is
select nvl(AMORT_INC_ADJ_REV_DT_YN, 'N')
  from okl_sys_acct_opts;

l_prb_enabled varchar2(1);

begin

   -- verify if the EDR feature is enabled for the OU.
   open is_prb_enabled;
   fetch is_prb_enabled into l_prb_enabled;
   close is_prb_enabled;

   -- proceed further if the feature is enabled.
   if l_prb_enabled = 'Y' then
     if p_context in ('BOTH', 'PRIMARY') then
       open get_prim_trx(p_khr_id);
	   fetch get_prim_trx into l_trx_number;
	   close get_prim_trx;

	    update okl_stream_trx_data
	       set last_trx_state = 'Y'
         where orig_khr_id = p_khr_id
	       and transaction_number = l_trx_number;

        update okl_stream_trx_data a
	       set a.last_trx_state = NULL
         where a.orig_khr_id = p_khr_id
	       and a.transaction_number < l_trx_number
		   and a.last_trx_state = 'Y'
		   and EXISTS (select b.transaction_number
		                 from okl_stream_interfaces b
				        where b.transaction_number = a.transaction_number
					      and b.purpose_code is NULL);
     end if;

     l_trx_number := NULL;

     if p_context in ('BOTH', 'REPORT') then
       open get_rep_trx(p_khr_id);
	   fetch get_rep_trx into l_trx_number;
	   close get_rep_trx;

       if l_trx_number is not null then
	      update okl_stream_trx_data
	         set last_trx_state = 'Y'
           where orig_khr_id = p_khr_id
	         and transaction_number = l_trx_number;

          update okl_stream_trx_data a
	         set a.last_trx_state = NULL
           where a.orig_khr_id = p_khr_id
	         and a.transaction_number < l_trx_number
		     and a.last_trx_state = 'Y'
		     and EXISTS (select b.transaction_number
		                   from okl_stream_interfaces b
				          where b.transaction_number = a.transaction_number
					        and b.purpose_code is NOT NULL);

       end if; -- if l_trx_number is not null

     end if;
   end if; -- if prb_enabled = 'Y'

end update_trx_state;

END  Okl_Streams_Util;

/
