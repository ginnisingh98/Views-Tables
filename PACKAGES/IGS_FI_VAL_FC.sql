--------------------------------------------------------
--  DDL for Package IGS_FI_VAL_FC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_VAL_FC" AUTHID CURRENT_USER AS
/* $Header: IGSFI24S.pls 115.4 2002/11/29 11:13:33 vvutukur ship $ */
  --
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur        29-Nov-2002  Enh#2584986.Obsoleted finp_val_fc_cur_upd.
  ----------------------------------------------------------------------------*/
  -- Validate update of fee category closed indicator.
  FUNCTION finp_val_fc_clsd_upd(
  p_fee_cat IN VARCHAR2 ,
  p_closed_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(finp_val_fc_clsd_upd,WNDS);
  --
-- Warn if IGS_FI_FEE_CAT.currency_cd change effects child records.
  FUNCTION finp_chk_rates_exist(
  p_fee_cat IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(finp_chk_rates_exist,WNDS);
END IGS_FI_VAL_FC;

 

/
