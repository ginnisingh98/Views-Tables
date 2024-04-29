--------------------------------------------------------
--  DDL for Package Body FARX_C_RP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FARX_C_RP" AS
/* $Header: FARXCRPB.pls 120.1.12010000.2 2009/07/19 11:54:23 glchen ship $ */

--
-- PROCEDURE Mass_Reclass_Preview
--

PROCEDURE Mass_Reclass_Preview(
	errbuf		 OUT NOCOPY VARCHAR2,
	retcode		 OUT NOCOPY VARCHAR2,
	argument1		IN	VARCHAR2,
	argument2		IN	VARCHAR2 := NULL,
	argument3		IN	VARCHAR2 := NULL,
	argument4		IN	VARCHAR2 := NULL,
	argument5		IN	VARCHAR2 := NULL,
	argument6		IN	VARCHAR2 := NULL,
	argument7		IN	VARCHAR2 := NULL,
	argument8		IN	VARCHAR2 := NULL,
	argument9		IN	VARCHAR2 := NULL,
	argument10		IN	VARCHAR2 := NULL,
	argument11		IN	VARCHAR2 := NULL,
	argument12		IN	VARCHAR2 := NULL,
	argument13		IN	VARCHAR2 := NULL,
	argument14		IN	VARCHAR2 := NULL,
	argument15		IN	VARCHAR2 := NULL,
	argument16		IN	VARCHAR2 := NULL,
	argument17		IN	VARCHAR2 := NULL,
	argument18		IN	VARCHAR2 := NULL,
	argument19		IN	VARCHAR2 := NULL,
	argument20		IN	VARCHAR2 := NULL,
	argument21		IN	VARCHAR2 := NULL,
	argument22		IN	VARCHAR2 := NULL,
	argument23		IN	VARCHAR2 := NULL,
	argument24		IN	VARCHAR2 := NULL,
	argument25		IN	VARCHAR2 := NULL,
	argument26		IN	VARCHAR2 := NULL,
	argument27		IN	VARCHAR2 := NULL,
	argument28		IN	VARCHAR2 := NULL,
	argument29		IN	VARCHAR2 := NULL,
	argument30		IN	VARCHAR2 := NULL,
	argument31		IN	VARCHAR2 := NULL,
	argument32		IN	VARCHAR2 := NULL,
	argument33		IN	VARCHAR2 := NULL,
	argument34		IN	VARCHAR2 := NULL,
	argument35		IN	VARCHAR2 := NULL,
	argument36		IN	VARCHAR2 := NULL,
	argument37		IN	VARCHAR2 := NULL,
	argument38		IN	VARCHAR2 := NULL,
	argument39		IN	VARCHAR2 := NULL,
	argument40		IN	VARCHAR2 := NULL,
	argument41		IN	VARCHAR2 := NULL,
	argument42		IN	VARCHAR2 := NULL,
	argument43		IN	VARCHAR2 := NULL,
	argument44		IN	VARCHAR2 := NULL,
	argument45		IN	VARCHAR2 := NULL,
	argument46		IN	VARCHAR2 := NULL,
	argument47		IN	VARCHAR2 := NULL,
	argument48		IN	VARCHAR2 := NULL,
	argument49		IN	VARCHAR2 := NULL,
	argument50		IN	VARCHAR2 := NULL,
	argument51		IN	VARCHAR2 := NULL,
	argument52		IN	VARCHAR2 := NULL,
	argument53		IN	VARCHAR2 := NULL,
	argument54		IN	VARCHAR2 := NULL,
	argument55		IN	VARCHAR2 := NULL,
	argument56		IN	VARCHAR2 := NULL,
	argument57		IN	VARCHAR2 := NULL,
	argument58		IN	VARCHAR2 := NULL,
	argument59		IN	VARCHAR2 := NULL,
	argument60		IN	VARCHAR2 := NULL,
	argument61		IN	VARCHAR2 := NULL,
	argument62		IN	VARCHAR2 := NULL,
	argument63		IN	VARCHAR2 := NULL,
	argument64		IN	VARCHAR2 := NULL,
	argument65		IN	VARCHAR2 := NULL,
	argument66		IN	VARCHAR2 := NULL,
	argument67		IN	VARCHAR2 := NULL,
	argument68		IN	VARCHAR2 := NULL,
	argument69		IN	VARCHAR2 := NULL,
	argument70		IN	VARCHAR2 := NULL,
	argument71		IN	VARCHAR2 := NULL,
	argument72		IN	VARCHAR2 := NULL,
	argument73		IN	VARCHAR2 := NULL,
	argument74		IN	VARCHAR2 := NULL,
	argument75		IN	VARCHAR2 := NULL,
	argument76		IN	VARCHAR2 := NULL,
	argument77		IN	VARCHAR2 := NULL,
	argument78		IN	VARCHAR2 := NULL,
	argument79		IN	VARCHAR2 := NULL,
	argument80		IN	VARCHAR2 := NULL,
	argument81		IN	VARCHAR2 := NULL,
	argument82		IN	VARCHAR2 := NULL,
	argument83		IN	VARCHAR2 := NULL,
	argument84		IN	VARCHAR2 := NULL,
	argument85		IN	VARCHAR2 := NULL,
	argument86		IN	VARCHAR2 := NULL,
	argument87		IN	VARCHAR2 := NULL,
	argument88		IN	VARCHAR2 := NULL,
	argument89		IN	VARCHAR2 := NULL,
	argument90		IN	VARCHAR2 := NULL,
	argument91		IN	VARCHAR2 := NULL,
	argument92		IN	VARCHAR2 := NULL,
	argument93		IN	VARCHAR2 := NULL,
	argument94		IN	VARCHAR2 := NULL,
	argument95		IN	VARCHAR2 := NULL,
	argument96		IN	VARCHAR2 := NULL,
	argument97		IN	VARCHAR2 := NULL,
	argument98		IN	VARCHAR2 := NULL,
	argument99		IN	VARCHAR2 := NULL,
	argument100		IN	VARCHAR2 := NULL) IS
    h_mesg_str		VARCHAR2(2000);
    h_count		NUMBER;
    h_status		BOOLEAN;
    h_retcode           VARCHAR2(3);
    -- error in the concurrent wrapper
    conc_failure 	EXCEPTION;

BEGIN
    /* Validate the arguments passed in. */
    IF argument1 IS NULL THEN
	fnd_message.set_name('OFA','FA_MRCL_PARAM_REQUIRED');
        h_mesg_str := fnd_message.get;
        fa_rx_conc_mesg_pkg.log(h_mesg_str);
	raise conc_failure;
    END IF;

    -- This argument must exist in the table.
    SELECT count(1) INTO h_count
    FROM fa_mass_reclass
    WHERE mass_reclass_id = to_number(argument1) AND rownum < 2;

    IF (h_count = 0) THEN
        fnd_message.set_name('OFA','FA_MRCL_PARAM_REQUIRED');
        h_mesg_str := fnd_message.get;
        fa_rx_conc_mesg_pkg.log(h_mesg_str);
	raise conc_failure;
    END IF;

    /* No data type conversion is necessary. */

    /* Call the inner procedure to preview reclass. */
    FARX_RP.Preview_Reclass(
	X_Mass_Reclass_Id	=> to_number(argument1),
	X_RX_Flag		=> 'YES',
	retcode			=> h_retcode,
	errbuf			=> errbuf);

    IF (h_retcode = 0) THEN
        retcode := 0;
    ELSIF (h_retcode = 1) THEN
        retcode := 1;
    ELSE
        retcode := 2;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
	retcode := 2;  -- Completed with error.
        /* A fatal error has occurred, rollback transaction and update status
           to 'FAILED_PRE' and commit the change. */
        ROLLBACK WORK;
        UPDATE fa_mass_reclass
        SET status = 'FAILED_PRE'
        WHERE mass_reclass_id = to_number(argument1);
	COMMIT WORK;
        IF SQLCODE <> 0 THEN
	  fa_rx_conc_mesg_pkg.log(SQLERRM);
        END IF;
END Mass_Reclass_Preview;

END FARX_C_RP;

/
