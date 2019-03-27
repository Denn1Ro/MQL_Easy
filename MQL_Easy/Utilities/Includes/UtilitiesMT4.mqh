//+------------------------------------------------------------------+
//|                                                 UtilitiesMT4.mqh |
//|                           Copyright 2018, Dionisis Nikolopoulos. |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Dionisis Nikolopoulos."
#property link      ""
#property version   "1.00"
#property strict

#include "UtilitiesBase.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CUtilities : public CUtilitiesBase
  {
private:

public:
                     CUtilities(string symbolPar = NULL);
                    ~CUtilities();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CUtilities::CUtilities(string symbolPar = NULL) : CUtilitiesBase(symbolPar)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CUtilities::~CUtilities()
  {
  }
//+------------------------------------------------------------------+
