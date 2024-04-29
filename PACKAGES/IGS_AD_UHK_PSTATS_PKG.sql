--------------------------------------------------------
--  DDL for Package IGS_AD_UHK_PSTATS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_UHK_PSTATS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSADD7S.pls 120.0 2006/05/02 05:20:32 apadegal noship $ */

  --
  --  User Hook - which can be customisable by the customer.
  --

  PROCEDURE Derive_Person_Stats(
    p_person_id              IN  NUMBER,
    x_init_cal_type          OUT NOCOPY VARCHAR2,
    x_init_sequence_number   OUT NOCOPY NUMBER,
    x_recent_cal_type        OUT NOCOPY VARCHAR2,
    x_recent_sequence_number OUT NOCOPY NUMBER
    ) ;

   --  Who         When            What
  --  apadegal    16/02/2006        Created the procedure

  --
  --  Parameters Description:
  --
  --  IN :
  --
  --  p_person_id		      parametet   Applicant Person Identifier
  --
  --  OUT:
  --
  --  x_init_cal_type              -- captures  Calander Type of the Initial Admittance Term
  --  x_init_sequence_number	   -- captures  Calendar Sequence number of the Initial Admittance Term
  --  x_recent_cal_type number	   -- captures  Calander Type of the Most Recent Admittance Term
  --  x_recent_sequence_number     -- captures	Calendar Sequence number of the Most Recent Initial Admittance Term
  --
  --  Note:
  --       1. The person statistics form ( IGSPE013) allows only active load calendars/academic calendars
  --            for Initial and Most Recent Admittance term values. (If any other values are set, Form would give an error)
  --       2. Even if this user hook passes back values of Most recent admittance term,
  --            these values will not be saved unless the profile value of IGS:Person Most Recent Admittance Term
  --	        is set to Accepted Application Offer Only

END IGS_AD_UHK_PSTATS_PKG;

 

/
