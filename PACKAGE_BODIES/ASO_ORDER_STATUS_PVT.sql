--------------------------------------------------------
--  DDL for Package Body ASO_ORDER_STATUS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_ORDER_STATUS_PVT" AS
/* $Header: asogtstb.pls 120.1 2005/06/29 12:31:37 appldev ship $ */

  PROCEDURE Get_Header_Status
  (
    p_Header_Id         IN NUMBER
    , x_Return_Status   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  ) IS

    l_result_date    DATE;
    l_latest_date    DATE := NULL;
    l_result         VARCHAR2(1);
    l_return_status  VARCHAR2(20) := NULL;

  BEGIN

    OE_HEADER_STATUS_PUB.Get_Booked_Status
    (
      p_header_id    => p_Header_Id
      , x_result     => l_result
      , x_result_date  => l_result_date
    );

    IF ( l_result = 'Y' ) THEN

      l_return_status := 'BOOKED';
      l_latest_date := l_result_date;

    END IF;


    OE_HEADER_STATUS_PUB.Get_Closed_Status
    (
      p_header_id    => p_Header_Id
      , x_result     => l_result
      , x_result_date  => l_result_date
    );

    IF ( l_result = 'Y' ) THEN

      IF ( l_latest_date IS NULL OR l_result_date > l_latest_date ) THEN

        l_latest_date   := l_result_date;
        l_return_status := 'CLOSED';

      END IF;

    END IF;

    OE_HEADER_STATUS_PUB.Get_Cancelled_Status
    (
      p_header_id    => p_Header_Id
      , x_result     => l_result
      , x_result_date  => l_result_date
    );

    IF ( l_result = 'Y' ) THEN

      IF ( l_latest_date IS NULL OR l_result_date > l_latest_date ) THEN

        l_latest_date   := l_result_date;
        l_return_status := 'CANCELLED';

      END IF;

    END IF;

    IF ( l_return_status IS NULL ) THEN

	 l_return_status := 'ENTERED';

    END IF;

    x_Return_Status := l_return_status;

  END Get_Header_Status;


  PROCEDURE Get_Line_Status
  (
    p_Line_Id           IN NUMBER
    , x_Return_Status   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  ) IS

    l_result_date    DATE;
    l_latest_date    DATE := NULL;
    l_result         VARCHAR2(1);
    l_return_status  VARCHAR2(20) := NULL;

  BEGIN

    OE_LINE_STATUS_PUB.Get_Closed_Status
    (
      p_line_id        => p_Line_Id
      , x_result       => l_result
      , x_result_date  => l_result_date
    );

    IF ( l_result = 'Y' ) THEN

      l_latest_date := l_result_date;
      l_return_status := 'CLOSED';

    END IF;

    OE_LINE_STATUS_PUB.Get_Cancelled_Status
    (
      p_line_id        => p_Line_Id
      , x_result       => l_result
      , x_result_date  => l_result_date
    );

    IF ( l_result = 'Y' ) THEN

      IF ( l_latest_date IS NULL OR l_result_date > l_latest_date ) THEN

        l_latest_date   := l_result_date;
        l_return_status := 'CANCELLED';

      END IF;

    END IF;

    OE_LINE_STATUS_PUB.Get_Purchase_Release_status
    (
      p_line_id        => p_Line_Id
      , x_result       => l_result
      , x_result_date  => l_result_date
    );

    IF ( l_result = 'Y' ) THEN

      IF ( l_latest_date IS NULL OR l_result_date > l_latest_date ) THEN

        l_latest_date   := l_result_date;
        l_return_status := 'RELEASED';

      END IF;

    END IF;

    OE_LINE_STATUS_PUB.Get_ship_Status
    (
      p_line_id        => p_Line_Id
      , x_result       => l_result
      , x_result_date  => l_result_date
    );


    IF ( l_result = 'Y' ) THEN

      IF ( l_latest_date IS NULL OR l_result_date > l_latest_date ) THEN

        l_latest_date   := l_result_date;
        l_return_status := 'SHIPPED';

      END IF;

    END IF;

    OE_LINE_STATUS_PUB.Get_Received_Status
    (
      p_line_id        => p_Line_Id
      , x_result       => l_result
      , x_result_date  => l_result_date
    );

    IF ( l_result = 'Y' ) THEN

      IF ( l_latest_date IS NULL OR l_result_date > l_latest_date ) THEN

        l_latest_date   := l_result_date;
        l_return_status := 'RECEIVED';

      END IF;

    END IF;

    OE_LINE_STATUS_PUB.Get_Invoiced_Status
    (
      p_line_id        => p_Line_Id
      , x_result       => l_result
      , x_result_date  => l_result_date
    );

    IF ( l_result = 'Y' ) THEN

      IF ( l_latest_date IS NULL OR l_result_date > l_latest_date ) THEN

        l_latest_date   := l_result_date;
        l_return_status := 'INVOICED';

      END IF;

    END IF;

    IF ( l_return_status IS NULL ) THEN

	 l_return_status := 'ENTERED';

    END IF;

    x_Return_Status := l_return_status;

  END Get_Line_Status;


END Aso_Order_Status_Pvt;

/
