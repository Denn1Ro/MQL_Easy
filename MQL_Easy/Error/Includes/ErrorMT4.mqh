//+------------------------------------------------------------------+
//|                                                     ErrorMT4.mqh |
//|                           Copyright 2018, Dionisis Nikolopoulos. |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Dionisis Nikolopoulos."
#property link      ""
#property version   "1.00"
#property strict

#include "ErrorBase.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CError : public CErrorBase
  {
private:

public:
                     CError();
                    ~CError();
  virtual string    ErrorDescr(int errorCodePar);
                       
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CError::CError()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CError::~CError()
  {
  }
//+------------------------------------------------------------------+




//+-----------------------------------------------+
//|                MQL5 PLATFORM                  |
//+-----------------------------------------------+ 
//+------------------------------------------------------------------+
//| return error description                                         |
//+------------------------------------------------------------------+
string CError::ErrorDescr(int errorCodePar)
  {
   string errorStr;
   switch(errorCodePar)
     {
      //--- codes returned from trade server
      case 0:   errorStr="no error";                                                   break;
      case 1:   errorStr="no error, trade conditions not changed";                     break;
      case 2:   errorStr="common error";                                               break;
      case 3:   errorStr="invalid trade parameters";                                   break;
      case 4:   errorStr="trade server is busy";                                       break;
      case 5:   errorStr="old version of the client terminal";                         break;
      case 6:   errorStr="no connection with trade server";                            break;
      case 7:   errorStr="not enough rights";                                          break;
      case 8:   errorStr="too frequent requests";                                      break;
      case 9:   errorStr="malfunctional trade operation (never returned error)";       break;
      case 64:  errorStr="account disabled";                                           break;
      case 65:  errorStr="invalid account";                                            break;
      case 128: errorStr="trade timeout";                                              break;
      case 129: errorStr="invalid price";                                              break;
      case 130: errorStr="invalid stops";                                              break;
      case 131: errorStr="invalid trade volume";                                       break;
      case 132: errorStr="market is closed";                                           break;
      case 133: errorStr="trade is disabled";                                          break;
      case 134: errorStr="not enough money";                                           break;
      case 135: errorStr="price changed";                                              break;
      case 136: errorStr="off quotes";                                                 break;
      case 137: errorStr="broker is busy (never returned error)";                      break;
      case 138: errorStr="requote";                                                    break;
      case 139: errorStr="order is locked";                                            break;
      case 140: errorStr="long positions only allowed";                                break;
      case 141: errorStr="too many requests";                                          break;
      case 145: errorStr="modification denied because order is too close to market";   break;
      case 146: errorStr="trade context is busy";                                      break;
      case 147: errorStr="expirations are denied by broker";                           break;
      case 148: errorStr="amount of open and pending orders has reached the limit";    break;
      case 149: errorStr="hedging is prohibited";                                      break;
      case 150: errorStr="prohibited by FIFO rules";                                   break;
      //--- mql4 errors
      case 4000: errorStr="no error (never generated code)";                           break;
      case 4001: errorStr="wrong function pointer";                                    break;
      case 4002: errorStr="array index is out of range";                               break;
      case 4003: errorStr="no memory for function call stack";                         break;
      case 4004: errorStr="recursive stack overflow";                                  break;
      case 4005: errorStr="not enough stack for parameter";                            break;
      case 4006: errorStr="no memory for parameter string";                            break;
      case 4007: errorStr="no memory for temp string";                                 break;
      case 4008: errorStr="non-initialized string";                                    break;
      case 4009: errorStr="non-initialized string in array";                           break;
      case 4010: errorStr="no memory for array\' string";                              break;
      case 4011: errorStr="too long string";                                           break;
      case 4012: errorStr="remainder from zero divide";                                break;
      case 4013: errorStr="zero divide";                                               break;
      case 4014: errorStr="unknown command";                                           break;
      case 4015: errorStr="wrong jump (never generated error)";                        break;
      case 4016: errorStr="non-initialized array";                                     break;
      case 4017: errorStr="dll calls are not allowed";                                 break;
      case 4018: errorStr="cannot load library";                                       break;
      case 4019: errorStr="cannot call function";                                      break;
      case 4020: errorStr="expert function calls are not allowed";                     break;
      case 4021: errorStr="not enough memory for temp string returned from function";  break;
      case 4022: errorStr="system is busy (never generated error)";                    break;
      case 4023: errorStr="dll-function call critical error";                          break;
      case 4024: errorStr="internal error";                                            break;
      case 4025: errorStr="out of memory";                                             break;
      case 4026: errorStr="invalid pointer";                                           break;
      case 4027: errorStr="too many formatters in the format function";                break;
      case 4028: errorStr="parameters count is more than formatters count";            break;
      case 4029: errorStr="invalid array";                                             break;
      case 4030: errorStr="no reply from chart";                                       break;
      case 4050: errorStr="invalid function parameters count";                         break;
      case 4051: errorStr="invalid function parameter value";                          break;
      case 4052: errorStr="string function internal error";                            break;
      case 4053: errorStr="some array error";                                          break;
      case 4054: errorStr="incorrect series array usage";                              break;
      case 4055: errorStr="custom indicator error";                                    break;
      case 4056: errorStr="arrays are incompatible";                                   break;
      case 4057: errorStr="global variables processing error";                         break;
      case 4058: errorStr="global variable not found";                                 break;
      case 4059: errorStr="function is not allowed in testing mode";                   break;
      case 4060: errorStr="function is not confirmed";                                 break;
      case 4061: errorStr="send mail error";                                           break;
      case 4062: errorStr="string parameter expected";                                 break;
      case 4063: errorStr="integer parameter expected";                                break;
      case 4064: errorStr="double parameter expected";                                 break;
      case 4065: errorStr="array as parameter expected";                               break;
      case 4066: errorStr="requested history data is in update state";                 break;
      case 4067: errorStr="internal trade error";                                      break;
      case 4068: errorStr="resource not found";                                        break;
      case 4069: errorStr="resource not supported";                                    break;
      case 4070: errorStr="duplicate resource";                                        break;
      case 4071: errorStr="cannot initialize custom indicator";                        break;
      case 4072: errorStr="cannot load custom indicator";                              break;
      case 4073: errorStr="no history data";                                           break;
      case 4074: errorStr="not enough memory for history data";                        break;
      case 4075: errorStr="not enough memory for indicator";                           break;
      case 4099: errorStr="end of file";                                               break;
      case 4100: errorStr="some file error";                                           break;
      case 4101: errorStr="wrong file name";                                           break;
      case 4102: errorStr="too many opened files";                                     break;
      case 4103: errorStr="cannot open file";                                          break;
      case 4104: errorStr="incompatible access to a file";                             break;
      case 4105: errorStr="no order selected";                                         break;
      case 4106: errorStr="unknown symbol";                                            break;
      case 4107: errorStr="invalid price parameter for trade function";                break;
      case 4108: errorStr="invalid ticket";                                            break;
      case 4109: errorStr="trade is not allowed in the expert properties";             break;
      case 4110: errorStr="longs are not allowed in the expert properties";            break;
      case 4111: errorStr="shorts are not allowed in the expert properties";           break;
      case 4200: errorStr="object already exists";                                     break;
      case 4201: errorStr="unknown object property";                                   break;
      case 4202: errorStr="object does not exist";                                     break;
      case 4203: errorStr="unknown object type";                                       break;
      case 4204: errorStr="no object name";                                            break;
      case 4205: errorStr="object coordinates error";                                  break;
      case 4206: errorStr="no specified subwindow";                                    break;
      case 4207: errorStr="graphical object error";                                    break;
      case 4210: errorStr="unknown chart property";                                    break;
      case 4211: errorStr="chart not found";                                           break;
      case 4212: errorStr="chart subwindow not found";                                 break;
      case 4213: errorStr="chart indicator not found";                                 break;
      case 4220: errorStr="symbol select error";                                       break;
      case 4250: errorStr="notification error";                                        break;
      case 4251: errorStr="notification parameter error";                              break;
      case 4252: errorStr="notifications disabled";                                    break;
      case 4253: errorStr="notification send too frequent";                            break;
      case 4260: errorStr="ftp server is not specified";                               break;
      case 4261: errorStr="ftp login is not specified";                                break;
      case 4262: errorStr="ftp connect failed";                                        break;
      case 4263: errorStr="ftp connect closed";                                        break;
      case 4264: errorStr="ftp change path error";                                     break;
      case 4265: errorStr="ftp file error";                                            break;
      case 4266: errorStr="ftp error";                                                 break;
      case 5001: errorStr="too many opened files";                                     break;
      case 5002: errorStr="wrong file name";                                           break;
      case 5003: errorStr="too long file name";                                        break;
      case 5004: errorStr="cannot open file";                                          break;
      case 5005: errorStr="text file buffer allocation error";                         break;
      case 5006: errorStr="cannot delete file";                                        break;
      case 5007: errorStr="invalid file handle (file closed or was not opened)";       break;
      case 5008: errorStr="wrong file handle (handle index is out of handle table)";   break;
      case 5009: errorStr="file must be opened with FILE_WRITE flag";                  break;
      case 5010: errorStr="file must be opened with FILE_READ flag";                   break;
      case 5011: errorStr="file must be opened with FILE_BIN flag";                    break;
      case 5012: errorStr="file must be opened with FILE_TXT flag";                    break;
      case 5013: errorStr="file must be opened with FILE_TXT or FILE_CSV flag";        break;
      case 5014: errorStr="file must be opened with FILE_CSV flag";                    break;
      case 5015: errorStr="file read error";                                           break;
      case 5016: errorStr="file write error";                                          break;
      case 5017: errorStr="string size must be specified for binary file";             break;
      case 5018: errorStr="incompatible file (for string arrays-TXT, for others-BIN)"; break;
      case 5019: errorStr="file is directory, not file";                               break;
      case 5020: errorStr="file does not exist";                                       break;
      case 5021: errorStr="file cannot be rewritten";                                  break;
      case 5022: errorStr="wrong directory name";                                      break;
      case 5023: errorStr="directory does not exist";                                  break;
      case 5024: errorStr="specified file is not directory";                           break;
      case 5025: errorStr="cannot delete directory";                                   break;
      case 5026: errorStr="cannot clean directory";                                    break;
      case 5027: errorStr="array resize error";                                        break;
      case 5028: errorStr="string resize error";                                       break;
      case 5029: errorStr="structure contains strings or dynamic arrays";              break;
      case 5200: errorStr="Invalid URL";                                               break;
      case 5201: errorStr="Failed to connect to specified URL";                        break;
      case 5202: errorStr="Timeout exceeded";                                          break;
      case 5203: errorStr="HTTP request failed";                                       break;
      case 65536: errorStr="User defined errors start with this code";                 break;
      default:   errorStr="unknown error";
     }
//---
   return(errorStr);
  } 
  
  