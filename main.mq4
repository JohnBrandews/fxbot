    //+------------------------------------------------------------------------------+//
    //)   ____  _  _  ____  ____  ____  ____  __  __    __      ___  _____  __  __   (//
    //)  ( ___)( \/ )(  _ \(  _ \( ___)( ___)(  \/  )  /__\    / __)(  _  )(  \/  )  (//
    //)   )__)  )  (  )(_) ))   / )__)  )__)  )    (  /(__)\  ( (__  )(_)(  )    (   (//
    //)  (__)  (_/\_)(____/(_)\_)(____)(____)(_/\/\_)(__)(__)()\___)(_____)(_/\/\_)  (//
    //)   https://fxdreema.com                             Copyright 2024, fxDreema  (//
    //+------------------------------------------------------------------------------+//
    #property copyright   ""
    #property link        "https://fxdreema.com"
    #property description ""
    #property version     "1.0"
    #property strict
    // Initialize AdaptiveRSI
AdaptiveRSI adaptiveRSI;

    /************************************************************************************************************************/
    // +------------------------------------------------------------------------------------------------------------------+ //
    // |                       INPUT PARAMETERS, GLOBAL VARIABLES, CONSTANTS, IMPORTS and INCLUDES                        | //
    // |                      System and Custom variables and other definitions used in the project                       | //
    // +------------------------------------------------------------------------------------------------------------------+ //
    /************************************************************************************************************************/

    //VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV//
    // System constants (project settings) //
    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^//
    //--
    #define PROJECT_ID "mt4-2669"
    //--
    // Point Format Rules
    #define POINT_FORMAT_RULES "0.001=0.01,0.00001=0.0001,0.000001=0.0001" // this is deserialized in a special function later
    #define ENABLE_SPREAD_METER true
    #define ENABLE_STATUS true
    #define ENABLE_TEST_INDICATORS true
    //--
    // Events On/Off
    #define ENABLE_EVENT_TICK 1 // enable "Tick" event
    #define ENABLE_EVENT_TRADE 0 // enable "Trade" event
    #define ENABLE_EVENT_TIMER 0 // enable "Timer" event
    //--
    // Virtual Stops
    #define VIRTUAL_STOPS_ENABLED 0 // enable virtual stops
    #define VIRTUAL_STOPS_TIMEOUT 0 // virtual stops timeout
    #define USE_EMERGENCY_STOPS "no" // "yes" to use emergency (hard stops) when virtual stops are in use. "always" to use EMERGENCY_STOPS_ADD as emergency stops when there is no virtual stop.
    #define EMERGENCY_STOPS_REL 0 // use 0 to disable hard stops when virtual stops are enabled. Use a value >=0 to automatically set hard stops with virtual. Example: if 2 is used, then hard stops will be 2 times bigger than virtual ones.
    #define EMERGENCY_STOPS_ADD 0 // add pips to relative size of emergency stops (hard stops)
    //--
    // Settings for events
    #define ON_TRADE_REALTIME 0 //
    #define ON_TIMER_PERIOD 60 // Timer event period (in seconds)

    //VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV//
    // System constants (predefined constants) //
    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^//
    //--
    // Blocks Lookup Functions
    string fxdBlocksLookupTable[];

    #define TLOBJPROP_TIME1 801
    #define OBJPROP_TL_PRICE_BY_SHIFT 802
    #define OBJPROP_TL_SHIFT_BY_PRICE 803
    #define OBJPROP_FIBOVALUE 804
    #define OBJPROP_FIBOPRICEVALUE 805
    #define OBJPROP_BARSHIFT1 807
    #define OBJPROP_BARSHIFT2 808
    #define OBJPROP_BARSHIFT3 809
    #define SEL_CURRENT 0
    #define SEL_INITIAL 1

    //VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV//
    // Enumerations, Imports, Constants, Variables //
    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^//






    //--
    // Constants (Input Parameters)
    input string MANSAMUSSA_2_0 = "Champion Trader";
    input int Percent_Balance = 1850;
    input int RSI_period = 14;
    input int Percent_Profit = 1000; // Percent_Profit (%)
    input int Percent_loss = 50; // Percent_loss (%0
    input int MagicStart = 3328; // Magic Number, kind of...
    class c
    {
            public:
        static string MANSAMUSSA_2_0;
        static int Percent_Balance;
        static int RSI_period;
        static int Percent_Profit;
        static int Percent_loss;
        static int MagicStart;
    };
    string c::MANSAMUSSA_2_0;
    int c::Percent_Balance;
    int c::RSI_period;
    int c::Percent_Profit;
    int c::Percent_loss;
    int c::MagicStart;


    //--
    // Variables (Global Variables)


    class v
    {
            public:
        static double Percentage_profit_BS;
        static double Percentage_Loss_BS;
    };
    double v::Percentage_profit_BS;
    double v::Percentage_Loss_BS;




    //VVVVVVVVVVVVVVVVVVVVVVVVV//
    // System global variables //
    //^^^^^^^^^^^^^^^^^^^^^^^^^//
    //--
    int FXD_CURRENT_FUNCTION_ID = 0;
    double FXD_MILS_INIT_END    = 0;
    int FXD_TICKS_FROM_START    = 0;
    int FXD_MORE_SHIFT          = 0;
    bool FXD_DRAW_SPREAD_INFO   = false;
    bool FXD_FIRST_TICK_PASSED  = false;
    bool FXD_BREAK              = false;
    bool FXD_CONTINUE           = false;
    bool FXD_CHART_IS_OFFLINE   = false;
    bool FXD_ONTIMER_TAKEN      = false;
    bool FXD_ONTIMER_TAKEN_IN_MILLISECONDS = false;
    double FXD_ONTIMER_TAKEN_TIME = 0;
    bool USE_VIRTUAL_STOPS = VIRTUAL_STOPS_ENABLED;
    string FXD_CURRENT_SYMBOL   = "";
    int FXD_BLOCKS_COUNT        = 19;
    datetime FXD_TICKSKIP_UNTIL = 0;

    //- for use in OnChart() event
    struct fxd_onchart
    {
        int id;
        long lparam;
        double dparam;
        string sparam;
    };
    fxd_onchart FXD_ONCHART;

    /************************************************************************************************************************/
    // +------------------------------------------------------------------------------------------------------------------+ //
    // |                                                 EVENT FUNCTIONS                                                  | //
    // |                           These are the main functions that controls the whole project                           | //
    // +------------------------------------------------------------------------------------------------------------------+ //
    /************************************************************************************************************************/

    //VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV//
    // This function is executed once when the program starts //
    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^//
    int OnInit()
    {

        // Initiate Constants
        c::MANSAMUSSA_2_0 = MANSAMUSSA_2_0;
        c::Percent_Balance = Percent_Balance;
        c::RSI_period = RSI_period;
        c::Percent_Profit = Percent_Profit;
        c::Percent_loss = Percent_loss;
        c::MagicStart = MagicStart;




        // do or do not not initilialize on reload
        if (UninitializeReason() != 0)
        {
            if (UninitializeReason() == REASON_CHARTCHANGE)
            {
                // if the symbol is the same, do not reload, otherwise continue below
                if (FXD_CURRENT_SYMBOL == Symbol()) {return INIT_SUCCEEDED;}
            }
            else
            {
                return INIT_SUCCEEDED;
            }
        }
        FXD_CURRENT_SYMBOL = Symbol();

        CurrentSymbol(FXD_CURRENT_SYMBOL); // CurrentSymbol() has internal memory that should be set from here when the symboll is changed
        CurrentTimeframe(PERIOD_CURRENT);

        v::Percentage_profit_BS = 0.0;
        v::Percentage_Loss_BS = 0.0;




        Comment("");
        for (int i=ObjectsTotal(ChartID()); i>=0; i--)
        {
            string name = ObjectName(ChartID(), i);
            if (StringSubstr(name,0,8) == "fxd_cmnt") {ObjectDelete(ChartID(), name);}
        }
        ChartRedraw();



        //-- disable virtual stops in optimization, because graphical objects does not work
        // http://docs.mql4.com/runtime/testing
        if (MQLInfoInteger(MQL_OPTIMIZATION) || (MQLInfoInteger(MQL_TESTER) && !MQLInfoInteger(MQL_VISUAL_MODE))) {
            USE_VIRTUAL_STOPS = false;
        }

        //-- set initial local and server time
        TimeAtStart("set");

        //-- set initial balance
        AccountBalanceAtStart();

        //-- draw the initial spread info meter
        if (ENABLE_SPREAD_METER == false) {
            FXD_DRAW_SPREAD_INFO = false;
        }
        else {
            FXD_DRAW_SPREAD_INFO = !(MQLInfoInteger(MQL_TESTER) && !MQLInfoInteger(MQL_VISUAL_MODE));
        }
        if (FXD_DRAW_SPREAD_INFO) DrawSpreadInfo();

        //-- draw initial status
        if (ENABLE_STATUS) DrawStatus("waiting for tick...");

        //-- draw indicators after test
        TesterHideIndicators(!ENABLE_TEST_INDICATORS);

        //-- working with offline charts
        if (MQLInfoInteger(MQL_PROGRAM_TYPE) == PROGRAM_EXPERT)
        {
            FXD_CHART_IS_OFFLINE = ChartGetInteger(0, CHART_IS_OFFLINE);
        }

        if (MQLInfoInteger(MQL_PROGRAM_TYPE) != PROGRAM_SCRIPT)
        {
            if (FXD_CHART_IS_OFFLINE == true || (ENABLE_EVENT_TRADE == 1 && ON_TRADE_REALTIME == 1))
            {
                FXD_ONTIMER_TAKEN = true;
                EventSetMillisecondTimer(1);
            }
            if (ENABLE_EVENT_TIMER) {
                OnTimerSet(ON_TIMER_PERIOD);
            }
        }


        //-- Initialize blocks classes
        ArrayResize(_blocks_, 19);

        _blocks_[0] = new Block0();
        _blocks_[1] = new Block1();
        _blocks_[2] = new Block2();
        _blocks_[3] = new Block3();
        _blocks_[4] = new Block4();
        _blocks_[5] = new Block5();
        _blocks_[6] = new Block6();
        _blocks_[7] = new Block7();
        _blocks_[8] = new Block8();
        _blocks_[9] = new Block9();
        _blocks_[10] = new Block10();
        _blocks_[11] = new Block11();
        _blocks_[12] = new Block12();
        _blocks_[13] = new Block13();
        _blocks_[14] = new Block14();
        _blocks_[15] = new Block15();
        _blocks_[16] = new Block16();
        _blocks_[17] = new Block17();
        _blocks_[18] = new Block18();

        // fill the lookup table
        ArrayResize(fxdBlocksLookupTable, ArraySize(_blocks_));
        for (int i=0; i<ArraySize(_blocks_); i++)
        {
            fxdBlocksLookupTable[i] = _blocks_[i].__block_user_number;
        }

        // fill the list of inbound blocks for each BlockCalls instance
        for (int i=0; i<ArraySize(_blocks_); i++)
        {
            _blocks_[i].__announceThisBlock();
        }

        // List of initially disabled blocks
        int disabled_blocks_list[] = {};
        for (int l = 0; l < ArraySize(disabled_blocks_list); l++) {
            _blocks_[disabled_blocks_list[l]].__disabled = true;
        }



        FXD_MILS_INIT_END     = (double)GetTickCount();
        FXD_FIRST_TICK_PASSED = false; // reset is needed when changing inputs

        return(INIT_SUCCEEDED);
    }

    //VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV//
    // This function is executed on every incoming tick //
    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^//
    void OnTick()
    {
        FXD_TICKS_FROM_START++;

        if (ENABLE_STATUS && FXD_TICKS_FROM_START == 1) DrawStatus("working");

        //-- special system actions
        if (FXD_DRAW_SPREAD_INFO) DrawSpreadInfo();
        TicksData(""); // Collect ticks (if needed)
        TicksPerSecond(false, true); // Collect ticks per second
        if (USE_VIRTUAL_STOPS) {VirtualStopsDriver();}

        if (false) ExpirationWorker * expirationDummy = new ExpirationWorker();
        expirationWorker.Run();

        if (OrdersTotal()) // this makes things faster
        {
            OCODriver(); // Check and close OCO orders
        }

        if (ENABLE_EVENT_TRADE) {OnTrade();}


        // skip ticks
        if (TimeLocal() < FXD_TICKSKIP_UNTIL) {return;}

        //-- run blocks
        int blocks_to_run[] = {0,9,13,17};
        for (int i=0; i<ArraySize(blocks_to_run); i++) {
            _blocks_[blocks_to_run[i]].run();
        }


        return;
    }



    //VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV//
    // This function is executed on every tick, because it's not native for MQL4  //
    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^//
    void OnTrade()
    {
        // This is needed so that the OnTradeEventDetector class is added into the code
        if (false) OnTradeEventDetector * dummy = new OnTradeEventDetector();

    }

    //VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV//
    // This function is executed on a period basis //
    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^//
    void OnTimer()
    {
        //-- to simulate ticks in offline charts, Timer is used instead of infinite loop
        //-- the next function checks for changes in price and calls OnTick() manually
        if (FXD_CHART_IS_OFFLINE && RefreshRates()) {
            OnTick();
        }
        if (ON_TRADE_REALTIME == 1) {
            OnTrade();
        }

        static datetime t0 = 0;
        datetime t = 0;
        bool ok = false;

        if (FXD_ONTIMER_TAKEN)
        {
            if (FXD_ONTIMER_TAKEN_TIME > 0)
            {
                if (FXD_ONTIMER_TAKEN_IN_MILLISECONDS == true)
                {
                    t = GetTickCount();
                }
                else
                {
                    t = TimeLocal();
                }
                if ((t - t0) >= FXD_ONTIMER_TAKEN_TIME)
                {
                    t0 = t;
                    ok = true;
                }
            }

            if (ok == false) {
                return;
            }
        }

    }


    //VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV//
    // This function is executed when chart event happens //
    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^//
    void OnChartEvent(
        const int id,         // Event ID
        const long& lparam,   // Parameter of type long event
        const double& dparam, // Parameter of type double event
        const string& sparam  // Parameter of type string events
    )
    {
        //-- write parameter to the system global variables
        FXD_ONCHART.id     = id;
        FXD_ONCHART.lparam = lparam;
        FXD_ONCHART.dparam = dparam;
        FXD_ONCHART.sparam = sparam;


        return;
    }

    //VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV//
    // This function is executed once when the program ends //
    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^//
    void OnDeinit(const int reason)
    {
        int reson = UninitializeReason();
        if (reson == REASON_CHARTCHANGE || reson == REASON_PARAMETERS || reason == REASON_TEMPLATE || reason == REASON_ACCOUNT ) {return;}

        //-- if Timer was set, kill it here
        EventKillTimer();

        if (ENABLE_STATUS) DrawStatus("stopped");
        if (ENABLE_SPREAD_METER) DrawSpreadInfo();
        ChartSetString(0, CHART_COMMENT, "");



        if (MQLInfoInteger(MQL_TESTER)) {
            Print("Backtested in "+DoubleToString((GetTickCount()-FXD_MILS_INIT_END)/1000, 2)+" seconds");
            double tc = GetTickCount()-FXD_MILS_INIT_END;
            if (tc > 0)
            {
                Print("Average ticks per second: "+DoubleToString(FXD_TICKS_FROM_START/tc, 0));
            }
        }

        if (MQLInfoInteger(MQL_PROGRAM_TYPE) == PROGRAM_EXPERT)
        {
            switch(UninitializeReason())
            {
                case REASON_PROGRAM     : Print("Expert Advisor self terminated"); break;
                case REASON_REMOVE      : Print("Expert Advisor removed from the chart"); break;
                case REASON_RECOMPILE   : Print("Expert Advisor has been recompiled"); break;
                case REASON_CHARTCHANGE : Print("Symbol or chart period has been changed"); break;
                case REASON_CHARTCLOSE  : Print("Chart has been closed"); break;
                case REASON_PARAMETERS  : Print("Input parameters have been changed by a user"); break;
                case REASON_ACCOUNT     : Print("Another account has been activated or reconnection to the trade server has occurred due to changes in the account settings"); break;
                case REASON_TEMPLATE    : Print("A new template has been applied"); break;
                case REASON_INITFAILED  : Print("OnInit() handler has returned a nonzero value"); break;
                case REASON_CLOSE       : Print("Terminal has been closed"); break;
            }
        }

        // delete dynamic pointers
        for (int i=0; i<ArraySize(_blocks_); i++)
        {
            delete _blocks_[i];
            _blocks_[i] = NULL;
        }
        ArrayResize(_blocks_, 0);

        return;
    }

    /************************************************************************************************************************/
    // +------------------------------------------------------------------------------------------------------------------+ //
    // |	                                         Classes of blocks                                                    | //
    // |              Classes that contain the actual code of the blocks and their input parameters as well               | //
    // +------------------------------------------------------------------------------------------------------------------+ //
    /************************************************************************************************************************/

    /**
        The base class for all block calls
    */
    class BlockCalls
    {
        public:
            bool __disabled; // whether or not the block is disabled

            string __block_user_number;
            int __block_number;
            int __block_waiting;
            int __parent_number;
            int __inbound_blocks[];
            int __outbound_blocks[];

            void __addInboundBlock(int id = 0) {
                int size = ArraySize(__inbound_blocks);
                for (int i = 0; i < size; i++) {
                    if (__inbound_blocks[i] == id) {
                        return;
                    }
                }
                ArrayResize(__inbound_blocks, size + 1);
                __inbound_blocks[size] = id;
            }

            void BlockCalls() {
                __disabled          = false;
                __block_user_number = "";
                __block_number      = 0;
                __block_waiting     = 0;
                __parent_number     = 0;
            }

            /**
             Announce this block to the list of inbound connections of all the blocks to which this block is connected to
            */
            void __announceThisBlock()
            {
            // add the current block number to the list of inbound blocks
            // for each outbound block that is provided
                for (int i = 0; i < ArraySize(__outbound_blocks); i++)
                {
                    int block = __outbound_blocks[i]; // outbound block number
                    int size  = ArraySize(_blocks_[block].__inbound_blocks); // the size of its inbound list

                    // skip if the current block was already added
                    for (int j = 0; j < size; j++) {
                        if (_blocks_[block].__inbound_blocks[j] == __block_number)
                        {
                            return;
                        }
                    }

                    // add the current block number to the list of inbound blocks of the other block
                    ArrayResize(_blocks_[block].__inbound_blocks, size + 1);
                    _blocks_[block].__inbound_blocks[size] = __block_number;
                }
            }

            // this is here, because it is used in the "run" function
            virtual void _execute_() = 0;

            /**
                In the derived class this method should be used to set dynamic parameters or other stuff before the main execute.
                This method is automatically called within the main "run" method below, before the execution of the main class.
                */
            virtual void _beforeExecute_() {return;};
            bool _beforeExecuteEnabled; // for speed

            /**
                Same as _beforeExecute_, but to work after the execute method.
                */
            virtual void _afterExecute_() {return;};
            bool _afterExecuteEnabled; // for speed

            /**
                This is the method that is used to run the block
                */
            virtual void run(int _parent_=0) {
                __parent_number = _parent_;
                if (__disabled || FXD_BREAK) {return;}
                FXD_CURRENT_FUNCTION_ID = __block_number;

                if (_beforeExecuteEnabled) {_beforeExecute_();}
                _execute_();
                if (_afterExecuteEnabled) {_afterExecute_();}

                if (__block_waiting && FXD_CURRENT_FUNCTION_ID == __block_number) {fxdWait.Accumulate(FXD_CURRENT_FUNCTION_ID);}
            }
    };

    BlockCalls *_blocks_[];


    // "No trade/order" model
    template<typename T1,typename T2,typename T3,typename T4,typename T5>
    class MDL_NoOrders: public BlockCalls
    {
        public: /* Input Parameters */
        T1 GroupMode;
        T2 Group;
        T3 SymbolMode;
        T4 Symbol;
        T5 BuysOrSells;
        virtual void _callback_(int r) {return;}

        public: /* Constructor */
        MDL_NoOrders()
        {
            GroupMode = (string)"group";
            Group = (string)"";
            SymbolMode = (string)"symbol";
            Symbol = (string)CurrentSymbol();
            BuysOrSells = (string)"both";
        }

        public: /* The main method */
        virtual void _execute_()
        {
            bool exist = false;
            
            for (int index = TradesTotal()-1; index >= 0; index--)
            {
                if (TradeSelectByIndex(index, GroupMode, Group, SymbolMode, Symbol, BuysOrSells))
                {
                    exist = true;
                    break;
                }
            }
            
            if (exist == false)
            {
                for (int index = OrdersTotal()-1; index >= 0; index--)
                {
                    if (PendingOrderSelectByIndex(index, GroupMode, Group, SymbolMode, Symbol, BuysOrSells))
                    {
                        exist = true;
                        break;
                    }
                }
            }
            
            if (exist == false) {_callback_(1);} else {_callback_(0);}
        }
    };

    // "Condition" model
    template<typename T1,typename _T1_,typename T2,typename T3,typename _T3_,typename T4>
    class MDL_Condition: public BlockCalls
    {
        public: /* Input Parameters */
        T1 Lo; virtual _T1_ _Lo_(){return(_T1_)0;}
        T2 compare;
        T3 Ro; virtual _T3_ _Ro_(){return(_T3_)0;}
        T4 crosswidth;
        virtual void _callback_(int r) {return;}

        public: /* Constructor */
        MDL_Condition()
        {
            compare = (string)">";
            crosswidth = (int)1;
        }

        public: /* The main method */
        virtual void _execute_()
        {
            bool output1 = false, output2 = false; // output 1 and output 2
            int crossover = 0;
            
            if (compare == "x>" || compare == "x<") {crossover = 1;}
            
            for (int i = 0; i <= crossover; i++)
            {
                // i=0 - normal pass, i=1 - crossover pass
            
                // Left operand of the condition
                FXD_MORE_SHIFT = i * crosswidth;
                _T1_ lo = _Lo_();
                if (MathAbs(lo) == EMPTY_VALUE) {return;}
            
                // Right operand of the condition
                FXD_MORE_SHIFT = i * crosswidth;
                _T3_ ro = _Ro_();
                if (MathAbs(ro) == EMPTY_VALUE) {return;}
            
                // Conditions
                if (CompareValues(compare, lo, ro))
                {
                    if (i == 0)
                    {
                        output1 = true;
                    }
                }
                else
                {
                    if (i == 0)
                    {
                        output2 = true;
                    }
                    else
                    {
                        output2 = false;
                    }
                }
            
                if (crossover == 1)
                {
                    if (CompareValues(compare, ro, lo))
                    {
                        if (i == 0)
                        {
                            output2 = true;
                        }
                    }
                    else
                    {
                        if (i == 1)
                        {
                            output1 = false;
                        }
                    }
                }
            }
            
            FXD_MORE_SHIFT = 0; // reset
            
                if (output1 == true) {_callback_(1);}
            else if (output2 == true) {_callback_(0);}
        }
    };

    // "OR" model
    class MDL_LogicalOR: public BlockCalls
    {
        /* Static Parameters */
        int old_tick;
        virtual void _callback_(int r) {return;}

        public: /* The main method */
        virtual void _execute_()
        {
            int tickID = FXD_TICKS_FROM_START;
            
            if (old_tick != tickID)
            {
                old_tick = tickID;
            
            _callback_(1);
            }
        }
    };

    // "Once per bar" model
    template<typename T1,typename T2,typename T3>
    class MDL_OncePerBar: public BlockCalls
    {
        public: /* Input Parameters */
        T1 Symbol;
        T2 Period;
        T3 PassMaxTimes;
        /* Static Parameters */
        string tokens[];
        int passes[];
        datetime old_values[];
        virtual void _callback_(int r) {return;}

        public: /* Constructor */
        MDL_OncePerBar()
        {
            Symbol = (string)CurrentSymbol();
            Period = (ENUM_TIMEFRAMES)CurrentTimeframe();
            PassMaxTimes = (int)1;
        }

        public: /* The main method */
        virtual void _execute_()
        {
            bool next    = false;
            string token = Symbol + IntegerToString(Period);
            int index    = ArraySearch(tokens, token);
            
            if (index == -1)
            {
                index = ArraySize(tokens);
                
                ArrayResize(tokens, index + 1);
                ArrayResize(old_values, index + 1);
                ArrayResize(passes, index + 1);
                
                tokens[index] = token;
                passes[index] = 0;
                old_values[index] = 0;
            }
            
            if (PassMaxTimes > 0)
            {
                // Sometimes CopyTime doesn't work properly. It happens when the history data is broken or something.
                // Then, CopyTime can't read any candles. It happens withing few candles only, but it's a problem that
                // I don't know how to fix. However, iTime() seems to work fine.
                datetime new_value = iTime(Symbol, Period, 1);
                
                if (new_value == 0) {
                    Print("Failed to get the time from candle 1 on symbol ", Symbol, " and timeframe ", EnumToString((ENUM_TIMEFRAMES)Period), ". The history data needs to be fixed.");
                }
            
                if (new_value > old_values[index])
                {
                    passes[index]++;
            
                    if (passes[index] >= PassMaxTimes)
                    {
                        old_values[index]  = new_value;
                        passes[index] = 0;
                    }
            
                    next = true;
                }
            }
            
            if (next) {_callback_(1);} else {_callback_(0);}
        }
    };

    // "Buy now" model
    template<typename T1,typename T2,typename T3,typename T4,typename T5,typename T6,typename T7,typename T8,typename T9,typename _T9_,typename T10,typename T11,typename T12,typename T13,typename T14,typename T15,typename T16,typename T17,typename T18,typename T19,typename T20,typename T21,typename T22,typename T23,typename T24,typename T25,typename T26,typename T27,typename T28,typename T29,typename T30,typename T31,typename T32,typename T33,typename T34,typename T35,typename T36,typename T37,typename _T37_,typename T38,typename _T38_,typename T39,typename _T39_,typename T40,typename T41,typename T42,typename T43,typename T44,typename _T44_,typename T45,typename _T45_,typename T46,typename _T46_,typename T47,typename T48,typename T49,typename T50,typename T51,typename _T51_,typename T52,typename T53,typename T54>
    class MDL_BuyNow: public BlockCalls
    {
        public: /* Input Parameters */
        T1 Group;
        T2 Symbol;
        T3 VolumeMode;
        T4 VolumeSize;
        T5 VolumeSizeRisk;
        T6 VolumeRisk;
        T7 VolumePercent;
        T8 VolumeBlockPercent;
        T9 dVolumeSize; virtual _T9_ _dVolumeSize_(){return(_T9_)0;}
        T10 FixedRatioUnitSize;
        T11 FixedRatioDelta;
        T12 mmTradesPool;
        T13 mmMgInitialLots;
        T14 mmMgMultiplyOnLoss;
        T15 mmMgMultiplyOnProfit;
        T16 mmMgAddLotsOnLoss;
        T17 mmMgAddLotsOnProfit;
        T18 mmMgResetOnLoss;
        T19 mmMgResetOnProfit;
        T20 mm1326InitialLots;
        T21 mm1326Reverse;
        T22 mmFiboInitialLots;
        T23 mmDalembertInitialLots;
        T24 mmDalembertReverse;
        T25 mmLabouchereInitialLots;
        T26 mmLabouchereList;
        T27 mmLabouchereReverse;
        T28 mmSeqBaseLots;
        T29 mmSeqOnLoss;
        T30 mmSeqOnProfit;
        T31 mmSeqReverse;
        T32 VolumeUpperLimit;
        T33 StopLossMode;
        T34 StopLossPips;
        T35 StopLossPercentPrice;
        T36 StopLossPercentTP;
        T37 dlStopLoss; virtual _T37_ _dlStopLoss_(){return(_T37_)0;}
        T38 dpStopLoss; virtual _T38_ _dpStopLoss_(){return(_T38_)0;}
        T39 ddStopLoss; virtual _T39_ _ddStopLoss_(){return(_T39_)0;}
        T40 TakeProfitMode;
        T41 TakeProfitPips;
        T42 TakeProfitPercentPrice;
        T43 TakeProfitPercentSL;
        T44 dlTakeProfit; virtual _T44_ _dlTakeProfit_(){return(_T44_)0;}
        T45 dpTakeProfit; virtual _T45_ _dpTakeProfit_(){return(_T45_)0;}
        T46 ddTakeProfit; virtual _T46_ _ddTakeProfit_(){return(_T46_)0;}
        T47 ExpMode;
        T48 ExpDays;
        T49 ExpHours;
        T50 ExpMinutes;
        T51 dExp; virtual _T51_ _dExp_(){return(_T51_)0;}
        T52 Slippage;
        T53 MyComment;
        T54 ArrowColorBuy;
        virtual void _callback_(int r) {return;}

        public: /* Constructor */
        MDL_BuyNow()
        {
            Group = (string)"";
            Symbol = (string)CurrentSymbol();
            VolumeMode = (string)"fixed";
            VolumeSize = (double)0.1;
            VolumeSizeRisk = (double)50.0;
            VolumeRisk = (double)2.5;
            VolumePercent = (double)100.0;
            VolumeBlockPercent = (double)3.0;
            FixedRatioUnitSize = (double)0.01;
            FixedRatioDelta = (double)20.0;
            mmTradesPool = (int)0;
            mmMgInitialLots = (double)0.1;
            mmMgMultiplyOnLoss = (double)2.0;
            mmMgMultiplyOnProfit = (double)1.0;
            mmMgAddLotsOnLoss = (double)0.0;
            mmMgAddLotsOnProfit = (double)0.0;
            mmMgResetOnLoss = (int)0;
            mmMgResetOnProfit = (int)1;
            mm1326InitialLots = (double)0.1;
            mm1326Reverse = (bool)false;
            mmFiboInitialLots = (double)0.1;
            mmDalembertInitialLots = (double)0.1;
            mmDalembertReverse = (bool)false;
            mmLabouchereInitialLots = (double)0.1;
            mmLabouchereList = (string)"1,2,3,4,5,6";
            mmLabouchereReverse = (bool)false;
            mmSeqBaseLots = (double)0.1;
            mmSeqOnLoss = (string)"3,2,6";
            mmSeqOnProfit = (string)"1";
            mmSeqReverse = (bool)false;
            VolumeUpperLimit = (double)0.0;
            StopLossMode = (string)"fixed";
            StopLossPips = (double)50.0;
            StopLossPercentPrice = (double)0.55;
            StopLossPercentTP = (double)100.0;
            TakeProfitMode = (string)"fixed";
            TakeProfitPips = (double)50.0;
            TakeProfitPercentPrice = (double)0.55;
            TakeProfitPercentSL = (double)100.0;
            ExpMode = (string)"GTC";
            ExpDays = (int)0;
            ExpHours = (int)1;
            ExpMinutes = (int)0;
            Slippage = (ulong)4;
            MyComment = (string)"";
            ArrowColorBuy = (color)clrBlue;
        }

        public: /* The main method */
        virtual void _execute_()
        {
            //-- stops ------------------------------------------------------------------
            double sll = 0, slp = 0, tpl = 0, tpp = 0;
            
                if (StopLossMode == "fixed")         {slp = StopLossPips;}
            else if (StopLossMode == "dynamicPips")   {slp = _dpStopLoss_();}
            else if (StopLossMode == "dynamicDigits") {slp = toPips(_ddStopLoss_(),Symbol);}
            else if (StopLossMode == "dynamicLevel")  {sll = _dlStopLoss_();}
            else if (StopLossMode == "percentPrice")  {sll = SymbolAsk(Symbol) - (SymbolAsk(Symbol) * StopLossPercentPrice / 100);}
            
                if (TakeProfitMode == "fixed")         {tpp = TakeProfitPips;}
            else if (TakeProfitMode == "dynamicPips")   {tpp = _dpTakeProfit_();}
            else if (TakeProfitMode == "dynamicDigits") {tpp = toPips(_ddTakeProfit_(),Symbol);}
            else if (TakeProfitMode == "dynamicLevel")  {tpl = _dlTakeProfit_();}
            else if (TakeProfitMode == "percentPrice")  {tpl = SymbolAsk(Symbol) + (SymbolAsk(Symbol) * TakeProfitPercentPrice / 100);}
            
            if (StopLossMode == "percentTP") {
            if (tpp > 0) {slp = tpp*StopLossPercentTP/100;}
            if (tpl > 0) {slp = toPips(MathAbs(SymbolAsk(Symbol) - tpl), Symbol)*StopLossPercentTP/100;}
            }
            if (TakeProfitMode == "percentSL") {
            if (slp > 0) {tpp = slp*TakeProfitPercentSL/100;}
            if (sll > 0) {tpp = toPips(MathAbs(SymbolAsk(Symbol) - sll), Symbol)*TakeProfitPercentSL/100;}
            }
            
            //-- lots -------------------------------------------------------------------
            double lots = 0;
            double pre_sll = sll;
            
            if (pre_sll == 0) {
                pre_sll = SymbolAsk(Symbol);
            }
            
            double pre_sl_pips = toPips(SymbolAsk(Symbol)-(pre_sll-toDigits(slp,Symbol)), Symbol);
            
                if (VolumeMode == "fixed")            {lots = DynamicLots(Symbol, VolumeMode, VolumeSize);}
            else if (VolumeMode == "block-equity")     {lots = DynamicLots(Symbol, VolumeMode, VolumeBlockPercent);}
            else if (VolumeMode == "block-balance")    {lots = DynamicLots(Symbol, VolumeMode, VolumeBlockPercent);}
            else if (VolumeMode == "block-freemargin") {lots = DynamicLots(Symbol, VolumeMode, VolumeBlockPercent);}
            else if (VolumeMode == "equity")           {lots = DynamicLots(Symbol, VolumeMode, VolumePercent);}
            else if (VolumeMode == "balance")          {lots = DynamicLots(Symbol, VolumeMode, VolumePercent);}
            else if (VolumeMode == "freemargin")       {lots = DynamicLots(Symbol, VolumeMode, VolumePercent);}
            else if (VolumeMode == "equityRisk")       {lots = DynamicLots(Symbol, VolumeMode, VolumeRisk, pre_sl_pips);}
            else if (VolumeMode == "balanceRisk")      {lots = DynamicLots(Symbol, VolumeMode, VolumeRisk, pre_sl_pips);}
            else if (VolumeMode == "freemarginRisk")   {lots = DynamicLots(Symbol, VolumeMode, VolumeRisk, pre_sl_pips);}
            else if (VolumeMode == "fixedRisk")        {lots = DynamicLots(Symbol, VolumeMode, VolumeSizeRisk, pre_sl_pips);}
            else if (VolumeMode == "fixedRatio")       {lots = DynamicLots(Symbol, VolumeMode, FixedRatioUnitSize, FixedRatioDelta);}
            else if (VolumeMode == "dynamic")          {lots = _dVolumeSize_();}
            else if (VolumeMode == "1326")             {lots = Bet1326(Group, Symbol, mmTradesPool, mm1326InitialLots, mm1326Reverse);}
            else if (VolumeMode == "fibonacci")        {lots = BetFibonacci(Group, Symbol, mmTradesPool, mmFiboInitialLots);}
            else if (VolumeMode == "dalembert")        {lots = BetDalembert(Group, Symbol, mmTradesPool, mmDalembertInitialLots, mmDalembertReverse);}
            else if (VolumeMode == "labouchere")       {lots = BetLabouchere(Group, Symbol, mmTradesPool, mmLabouchereInitialLots, mmLabouchereList, mmLabouchereReverse);}
            else if (VolumeMode == "martingale")       {lots = BetMartingale(Group, Symbol, mmTradesPool, mmMgInitialLots, mmMgMultiplyOnLoss, mmMgMultiplyOnProfit, mmMgAddLotsOnLoss, mmMgAddLotsOnProfit, mmMgResetOnLoss, mmMgResetOnProfit);}
            else if (VolumeMode == "sequence")         {lots = BetSequence(Group, Symbol, mmTradesPool, mmSeqBaseLots, mmSeqOnLoss, mmSeqOnProfit, mmSeqReverse);}
            
            lots = AlignLots(Symbol, lots, 0, VolumeUpperLimit);
            
            datetime exp = ExpirationTime(ExpMode,ExpDays,ExpHours,ExpMinutes,_dExp_());
            
            //-- send -------------------------------------------------------------------
            long ticket = BuyNow(Symbol, lots, sll, tpl, slp, tpp, Slippage, (MagicStart+(int)Group), MyComment, ArrowColorBuy, exp);
            
            if (ticket > 0) {_callback_(1);} else {_callback_(0);}
        }
    };

    // "If trade" model
    template<typename T1,typename T2,typename T3,typename T4,typename T5>
    class MDL_IfOpenedOrders: public BlockCalls
    {
        public: /* Input Parameters */
        T1 GroupMode;
        T2 Group;
        T3 SymbolMode;
        T4 Symbol;
        T5 BuysOrSells;
        virtual void _callback_(int r) {return;}

        public: /* Constructor */
        MDL_IfOpenedOrders()
        {
            GroupMode = (string)"group";
            Group = (string)"";
            SymbolMode = (string)"symbol";
            Symbol = (string)CurrentSymbol();
            BuysOrSells = (string)"both";
        }

        public: /* The main method */
        virtual void _execute_()
        {
            bool exist = false;
            
            for (int index = TradesTotal()-1; index >= 0; index--)
            {
                if (TradeSelectByIndex(index, GroupMode, Group, SymbolMode, Symbol, BuysOrSells))
                {
                    exist = true;
                    break;
                }
            }
            
            if (exist == true) {_callback_(1);} else {_callback_(0);}
        }
    };

    // "Formula" model
    template<typename T1,typename _T1_,typename T2,typename T3,typename _T3_>
    class MDL_Formula_1: public BlockCalls
    {
        public: /* Input Parameters */
        T1 Lo; virtual _T1_ _Lo_(){return(_T1_)0;}
        T2 compare;
        T3 Ro; virtual _T3_ _Ro_(){return(_T3_)0;}
        virtual void _callback_(int r) {return;}

        public: /* Constructor */
        MDL_Formula_1()
        {
            compare = (string)"+";
        }

        public: /* The main method */
        virtual void _execute_()
        {
            _T1_ lo = _Lo_();
            if (typename(_T1_) != "string" && MathAbs(lo) == EMPTY_VALUE) {return;}
            
            _T3_ ro = _Ro_();
            if (typename(_T3_) != "string" && MathAbs(ro) == EMPTY_VALUE) {return;}
            
            v::Percentage_profit_BS = formula(compare, lo, ro)/100;
            
            _callback_(1);
        }
    };

    // "Check profit (unrealized)" model
    template<typename T1,typename T2,typename T3,typename T4,typename T5,typename T6,typename T7,typename T8,typename T9,typename T10,typename T11,typename T12,typename T13>
    class MDL_CheckUProfit: public BlockCalls
    {
        public: /* Input Parameters */
        T1 GroupMode;
        T2 Group;
        T3 SymbolMode;
        T4 Symbol;
        T5 BuysOrSells;
        T6 EachProfitMode;
        T7 EachCompare;
        T8 EachProfitAmount;
        T9 EachProfitAmountPips;
        T10 ProfitMode;
        T11 Compare;
        T12 ProfitAmount;
        T13 ProfitAmountPips;
        virtual void _callback_(int r) {return;}

        public: /* Constructor */
        MDL_CheckUProfit()
        {
            GroupMode = (string)"group";
            Group = (string)"";
            SymbolMode = (string)"symbol";
            Symbol = (string)CurrentSymbol();
            BuysOrSells = (string)"both";
            EachProfitMode = (string)"";
            EachCompare = (string)">";
            EachProfitAmount = (double)0.0;
            EachProfitAmountPips = (double)10.0;
            ProfitMode = (string)"money";
            Compare = (string)">";
            ProfitAmount = (double)0.0;
            ProfitAmountPips = (double)10.0;
        }

        public: /* The main method */
        virtual void _execute_()
        {
            double avgPrice    = 0;
            double avgLoad     = 0;
            double avgLots     = 0;
            double profitMoney = 0;
            double profitPips  = 0;
            double pipsSum     = 0;
            int tradesCount    = 0;
            
            for (int index = TradesTotal()-1; index >= 0; index--) {
                if (TradeSelectByIndex(index, GroupMode, Group, SymbolMode, Symbol, BuysOrSells)) {
                    double OrderOpenPrice = OrderChildOpenPrice();
                    double tradeProfit    = NormalizeDouble(OrderProfit() + OrderSwap() + OrderCommission(), 2);
            
                    // Filter out individual trades
                    if (EachProfitMode == "money") {
                        if (compare(EachCompare, tradeProfit, EachProfitAmount)) {/* do nothing */} else {continue;}
                    }
                    else if (EachProfitMode == "pips") {
                        double individual_profit = toPips(OrderClosePrice() - OrderOpenPrice, OrderSymbol());
            
                        if (OrderType() == 1) {individual_profit = -1 * individual_profit;}
            
                        if (compare(EachCompare, individual_profit, EachProfitAmountPips)) {/* do nothing*/} else {continue;}
                    }
            
                    profitMoney += tradeProfit;
            
                    if (ProfitMode == "pips" || ProfitMode == "pips-sum") {
                        if (IsOrderTypeBuy()) {
                            pipsSum += toPips(OrderClosePrice() - OrderOpenPrice, OrderSymbol());
                            avgLoad += OrderOpenPrice * OrderLots();
                            avgLots += OrderLots();
                        }
                        else {
                            pipsSum += toPips(OrderOpenPrice - OrderClosePrice(), OrderSymbol());
                            avgLoad -= OrderOpenPrice * OrderLots();
                            avgLots -= OrderLots();
                        }
                    }
            
                    tradesCount += 1;
                }
            }
            
            if (ProfitMode == "pips") {
                avgPrice = 0;
            
                if (avgLots != 0) {
                    avgPrice = (avgLoad / avgLots);
                }
            
                if (avgPrice != 0) {
                    if (avgLots > 0) {
                        profitPips = SymbolInfoDouble(Symbol, SYMBOL_BID) - avgPrice;
                    }
                    else {
                        profitPips = avgPrice - SymbolInfoDouble(Symbol, SYMBOL_ASK);
                    }
            
                    profitPips = toPips(profitPips, Symbol);
                }
            }
            
            if (
                (ProfitMode == "money"    && (CompareValues(Compare, profitMoney, ProfitAmount)))
                || (ProfitMode == "pips"     && (CompareValues(Compare, profitPips, ProfitAmountPips)))
                || (ProfitMode == "pips-sum" && (CompareValues(Compare, pipsSum, ProfitAmountPips)))
            ) {
                _callback_(1);
            }
            else {
                _callback_(0);
            }
        }
    };

    // "Close trades" model
    template<typename T1,typename T2,typename T3,typename T4,typename T5,typename T6,typename T7,typename T8>
    class MDL_CloseOpened: public BlockCalls
    {
        public: /* Input Parameters */
        T1 GroupMode;
        T2 Group;
        T3 SymbolMode;
        T4 Symbol;
        T5 BuysOrSells;
        T6 OrderMinutes;
        T7 Slippage;
        T8 ArrowColor;
        virtual void _callback_(int r) {return;}

        public: /* Constructor */
        MDL_CloseOpened()
        {
            GroupMode = (string)"group";
            Group = (string)"";
            SymbolMode = (string)"symbol";
            Symbol = (string)CurrentSymbol();
            BuysOrSells = (string)"both";
            OrderMinutes = (int)0;
            Slippage = (ulong)4;
            ArrowColor = (color)clrDeepPink;
        }

        public: /* The main method */
        virtual void _execute_()
        {
            int closed_count = 0;
            bool finished    = false;
            
            while (finished == false)
            {
                int count = 0;
            
                for (int index = TradesTotal()-1; index >= 0; index--)
                {
                    if (TradeSelectByIndex(index, GroupMode, Group, SymbolMode, Symbol, BuysOrSells))
                    {
                        datetime time_diff = TimeCurrent() - OrderOpenTime();
            
                        if (time_diff < 0) {time_diff = 0;} // this actually happens sometimes
            
                        if (time_diff >= 60 * OrderMinutes)
                        {
                            if (CloseTrade(OrderTicket(), Slippage, ArrowColor))
                            {
                                closed_count++;
                            }
            
                            count++;
                        }
                    }
                }
            
                if (count == 0) {finished = true;}
            }
            
            _callback_(1);
        }
    };

    // "Formula" model
    template<typename T1,typename _T1_,typename T2,typename T3,typename _T3_>
    class MDL_Formula_2: public BlockCalls
    {
        public: /* Input Parameters */
        T1 Lo; virtual _T1_ _Lo_(){return(_T1_)0;}
        T2 compare;
        T3 Ro; virtual _T3_ _Ro_(){return(_T3_)0;}
        virtual void _callback_(int r) {return;}

        public: /* Constructor */
        MDL_Formula_2()
        {
            compare = (string)"+";
        }

        public: /* The main method */
        virtual void _execute_()
        {
            _T1_ lo = _Lo_();
            if (typename(_T1_) != "string" && MathAbs(lo) == EMPTY_VALUE) {return;}
            
            _T3_ ro = _Ro_();
            if (typename(_T3_) != "string" && MathAbs(ro) == EMPTY_VALUE) {return;}
            
            v::Percentage_Loss_BS = formula(compare, lo, ro)/100;
            
            _callback_(1);
        }
    };

    // "Pass" model
    class MDL_Pass: public BlockCalls
    {
        virtual void _callback_(int r) {return;}

        public: /* The main method */
        virtual void _execute_()
        {
            _callback_(1);
        }
    };

    // "Comment" model
    template<typename T1,typename T2,typename T3,typename T4,typename T5,typename T6,typename T7,typename T8,typename T9,typename T10,typename T11,typename T12,typename T13,typename T14,typename T15,typename T16,typename _T16_,typename T17,typename T18,typename T19,typename T20,typename _T20_,typename T21,typename T22,typename T23,typename T24,typename _T24_,typename T25,typename T26,typename T27,typename T28,typename _T28_,typename T29,typename T30,typename T31,typename T32,typename _T32_,typename T33,typename T34,typename T35,typename T36,typename _T36_,typename T37,typename T38,typename T39,typename T40,typename _T40_,typename T41,typename T42,typename T43,typename T44,typename _T44_,typename T45,typename T46>
    class MDL_CommentEx: public BlockCalls
    {
        public: /* Input Parameters */
        T1 Title;
        T2 ObjChartSubWindow;
        T3 ObjCorner;
        T4 ObjX;
        T5 ObjY;
        T6 ObjTitleFont;
        T7 ObjTitleFontColor;
        T8 ObjTitleFontSize;
        T9 ObjLabelsFont;
        T10 ObjLabelsFontColor;
        T11 ObjLabelsFontSize;
        T12 ObjFont;
        T13 ObjFontColor;
        T14 ObjFontSize;
        T15 Label1;
        T16 Value1; virtual _T16_ _Value1_(){return(_T16_)0;}
        T17 FormatNumber1;
        T18 FormatTime1;
        T19 Label2;
        T20 Value2; virtual _T20_ _Value2_(){return(_T20_)0;}
        T21 FormatNumber2;
        T22 FormatTime2;
        T23 Label3;
        T24 Value3; virtual _T24_ _Value3_(){return(_T24_)0;}
        T25 FormatNumber3;
        T26 FormatTime3;
        T27 Label4;
        T28 Value4; virtual _T28_ _Value4_(){return(_T28_)0;}
        T29 FormatNumber4;
        T30 FormatTime4;
        T31 Label5;
        T32 Value5; virtual _T32_ _Value5_(){return(_T32_)0;}
        T33 FormatNumber5;
        T34 FormatTime5;
        T35 Label6;
        T36 Value6; virtual _T36_ _Value6_(){return(_T36_)0;}
        T37 FormatNumber6;
        T38 FormatTime6;
        T39 Label7;
        T40 Value7; virtual _T40_ _Value7_(){return(_T40_)0;}
        T41 FormatNumber7;
        T42 FormatTime7;
        T43 Label8;
        T44 Value8; virtual _T44_ _Value8_(){return(_T44_)0;}
        T45 FormatNumber8;
        T46 FormatTime8;
        /* Static Parameters */
        bool initialized;
        virtual void _callback_(int r) {return;}

        public: /* Constructor */
        MDL_CommentEx()
        {
            Title = (string)"Comment Message";
            ObjChartSubWindow = (string)"";
            ObjCorner = (int)CORNER_LEFT_UPPER;
            ObjX = (int)5;
            ObjY = (int)24;
            ObjTitleFont = (string)"Georgia";
            ObjTitleFontColor = (color)clrGold;
            ObjTitleFontSize = (int)13;
            ObjLabelsFont = (string)"Verdana";
            ObjLabelsFontColor = (color)clrDarkGray;
            ObjLabelsFontSize = (int)10;
            ObjFont = (string)"Verdana";
            ObjFontColor = (color)clrWhite;
            ObjFontSize = (int)10;
            Label1 = (string)"";
            FormatNumber1 = (int)EMPTY_VALUE;
            FormatTime1 = (int)EMPTY_VALUE;
            Label2 = (string)"";
            FormatNumber2 = (int)EMPTY_VALUE;
            FormatTime2 = (int)EMPTY_VALUE;
            Label3 = (string)"";
            FormatNumber3 = (int)EMPTY_VALUE;
            FormatTime3 = (int)EMPTY_VALUE;
            Label4 = (string)"";
            FormatNumber4 = (int)EMPTY_VALUE;
            FormatTime4 = (int)EMPTY_VALUE;
            Label5 = (string)"";
            FormatNumber5 = (int)EMPTY_VALUE;
            FormatTime5 = (int)EMPTY_VALUE;
            Label6 = (string)"";
            FormatNumber6 = (int)EMPTY_VALUE;
            FormatTime6 = (int)EMPTY_VALUE;
            Label7 = (string)"";
            FormatNumber7 = (int)EMPTY_VALUE;
            FormatTime7 = (int)EMPTY_VALUE;
            Label8 = (string)"";
            FormatNumber8 = (int)EMPTY_VALUE;
            FormatTime8 = (int)EMPTY_VALUE;
            /* Static Parameters (initial value) */
            initialized =  false;
        }

        public: /* The main method */
        virtual void _execute_()
        {
            if (!MQLInfoInteger(MQL_TESTER) || MQLInfoInteger(MQL_VISUAL_MODE))
            {
                
            
                long ObjChartID = 0;
                int ObjAnchor   = ANCHOR_LEFT;
            
                if (ObjCorner == CORNER_RIGHT_UPPER || ObjCorner == CORNER_RIGHT_LOWER)
                {
                    ObjAnchor = ANCHOR_RIGHT;
                }
            
                string namebase = "fxd_cmnt_" + __block_user_number;
            
                int subwindow = WindowFindVisible(ObjChartID, ObjChartSubWindow);
            
                if (subwindow >= 0)
                {
                    //-- draw comment title
                    if ((string)Title != "")
                    {
                        string nametitle = namebase;
            
                        if(ObjectFind(ObjChartID, nametitle) < 0)
                        {
                            if (!ObjectCreate(ObjChartID, nametitle, OBJ_LABEL, subwindow, 0, 0, 0, 0))
                            {
                                Print(__FUNCTION__, ": failed to create text object! Error code = ", GetLastError());
                            }
                            else
                            {
                                ObjectSetInteger(ObjChartID, nametitle, OBJPROP_FONTSIZE, (int)(ObjTitleFontSize));
                                ObjectSetInteger(ObjChartID, nametitle, OBJPROP_COLOR, ObjTitleFontColor);
                                ObjectSetInteger(ObjChartID, nametitle, OBJPROP_BACK, 0);
                                ObjectSetInteger(ObjChartID, nametitle, OBJPROP_SELECTABLE, 1);
                                ObjectSetInteger(ObjChartID, nametitle, OBJPROP_SELECTED, 0);
                                ObjectSetInteger(ObjChartID, nametitle, OBJPROP_HIDDEN, 1);
                                ObjectSetInteger(ObjChartID, nametitle, OBJPROP_CORNER, ObjCorner);
                                ObjectSetInteger(ObjChartID, nametitle, OBJPROP_ANCHOR, ObjAnchor);
            
                                ObjectSetString(ObjChartID, nametitle, OBJPROP_FONT, ObjTitleFont);
            
                                ObjectSetInteger(ObjChartID, nametitle, OBJPROP_XDISTANCE, ObjX);
                                ObjectSetInteger(ObjChartID, nametitle, OBJPROP_YDISTANCE, ObjY);
                            }
                        }
                        else
                        {
                            ObjX = (int)ObjectGetInteger(ObjChartID, nametitle, OBJPROP_XDISTANCE);
                            ObjY = (int)ObjectGetInteger(ObjChartID, nametitle, OBJPROP_YDISTANCE);
                        }
            
                        ObjectSetString(ObjChartID, nametitle, OBJPROP_TEXT, (string)Title);
            
                        ObjY = (int)(ObjY + ObjTitleFontSize / 3);
                    }
            
                    //-- draw comment rows
                    for (int i = 1; i <= 8; i++)
                    {
                        string text    = "";
                        string textlbl = "";
            
                        switch(i)
                        {
                            case 1:
                            {
                                if (Label1 != "")
                                {
                                    textlbl = Label1;
                                    text    = FormatValueForPrinting(_Value1_(), FormatNumber1, FormatTime1);
                                }
            
                                break;
                            }
                            case 2:
                            {
                                if (Label2 != "")
                                {
                                    textlbl = Label2;
                                    text    = FormatValueForPrinting(_Value2_(), FormatNumber2, FormatTime2);
                                }
            
                                break;
                            }
                            case 3:
                            {
                                if (Label3 != "")
                                {
                                    textlbl = Label3;
                                    text    = FormatValueForPrinting(_Value3_(), FormatNumber3, FormatTime3);
                                }
            
                                break;
                            }
                            case 4:
                            {
                                if (Label4 != "")
                                {
                                    textlbl = Label4;
                                    text    = FormatValueForPrinting(_Value4_(), FormatNumber4, FormatTime4);
                                }
            
                                break;
                            }
                            case 5:
                            {
                                if (Label5 != "")
                                {
                                    textlbl = Label5;
                                    text    = FormatValueForPrinting(_Value5_(), FormatNumber5, FormatTime5);
                                }
            
                                break;
                            }
                            case 6:
                            {
                                if (Label6 != "")
                                {
                                    textlbl = Label6;
                                    text    = FormatValueForPrinting(_Value6_(), FormatNumber6, FormatTime6);
                                }
            
                                break;
                            }
                            case 7:
                            {
                                if (Label7 != "")
                                {
                                    textlbl = Label7;
                                    text    = FormatValueForPrinting(_Value7_(), FormatNumber7, FormatTime7);
                                }
            
                                break;
                            }
                            case 8:
                            {
                                if (Label8 != "")
                                {
                                    textlbl = Label8;
                                    text    = FormatValueForPrinting(_Value8_(), FormatNumber8, FormatTime8);
                                }
            
                                break;
                            }
                    }
            
                        string name    = namebase + "_" + (string)i;
                        string namelbl = name + "_l";
            
                        if (textlbl == "")
                        {
                            if (!initialized)
                            {
                                //-- pre-delete
                                ObjectDelete(ObjChartID, namelbl);
                                ObjectDelete(ObjChartID, name);
                            }
            
                            continue;
                        }
            
                        //-- draw initial objects
                        if (ObjectFind(ObjChartID, name) < 0)
                        {
                            if (textlbl == "")
                            {
                                continue;
                            }
            
                            if (ObjectCreate(ObjChartID, namelbl, OBJ_LABEL, subwindow, 0, 0, 0, 0))
                            {
                                ObjectSetInteger(ObjChartID, namelbl, OBJPROP_CORNER, ObjCorner);
                                ObjectSetInteger(ObjChartID, namelbl, OBJPROP_ANCHOR, ObjAnchor);
                                ObjectSetInteger(ObjChartID, namelbl, OBJPROP_BACK, 0);
                                ObjectSetInteger(ObjChartID, namelbl, OBJPROP_SELECTABLE, 0);
                                ObjectSetInteger(ObjChartID, namelbl, OBJPROP_SELECTED, 0);
                                ObjectSetInteger(ObjChartID, namelbl, OBJPROP_HIDDEN, 1);
                                ObjectSetInteger(ObjChartID, namelbl, OBJPROP_FONTSIZE, ObjLabelsFontSize);
                                ObjectSetInteger(ObjChartID, namelbl, OBJPROP_COLOR, ObjLabelsFontColor);
                                ObjectSetString(ObjChartID, namelbl, OBJPROP_FONT, ObjLabelsFont);
                            }
                            else
                            {
                                Print(__FUNCTION__, ": failed to create text object! Error code = ", GetLastError());
                            }
            
                            if (ObjectCreate(ObjChartID, name, OBJ_LABEL, subwindow, 0, 0, 0, 0))
                            {
                                ObjectSetInteger(ObjChartID, name, OBJPROP_CORNER, ObjCorner);
                                ObjectSetInteger(ObjChartID, name, OBJPROP_ANCHOR, ObjAnchor);
                                ObjectSetInteger(ObjChartID, name, OBJPROP_BACK, 0);
                                ObjectSetInteger(ObjChartID, name, OBJPROP_SELECTABLE, 0);
                                ObjectSetInteger(ObjChartID, name, OBJPROP_SELECTED, 0);
                                ObjectSetInteger(ObjChartID, name, OBJPROP_HIDDEN, 1);
                                ObjectSetInteger(ObjChartID, name, OBJPROP_FONTSIZE, ObjFontSize);
                                ObjectSetInteger(ObjChartID, name, OBJPROP_COLOR, ObjFontColor);
                                ObjectSetString(ObjChartID, name, OBJPROP_FONT, ObjFont);
                            }
                            else
                            {
                                Print(__FUNCTION__, ": failed to create text object! Error code = ", GetLastError());
                            }
                        }
                        else
                        {
                            if (textlbl == "")
                            {
                                ObjectDelete(ObjChartID, namelbl);
                                ObjectDelete(ObjChartID, name);
                                continue;
                            }
                        }
            
                        ObjY  = (int)(ObjY + ObjFontSize + ObjFontSize/2);
            
                        //-- update label objects
                        ObjectSetInteger(ObjChartID, namelbl, OBJPROP_XDISTANCE, ObjX);
                        ObjectSetInteger(ObjChartID, namelbl, OBJPROP_YDISTANCE, ObjY);
                        ObjectSetString(ObjChartID, namelbl, OBJPROP_TEXT, (string)textlbl);
            
                        //-- update value objects
                        int x        = 0;
                        int xsizelbl = (int)ObjectGetInteger(ObjChartID, namelbl, OBJPROP_XSIZE);
            
                        if (xsizelbl == 0) {
                            //-- when the object is newly created, it returns 0 for XSIZE and YSIZE, so here we will trick it somehow
                            xsizelbl = (int)(StringLen((string)textlbl) * ObjFontSize / 1.5 + ObjFontSize / 2);
                        }
            
                        x = ObjX + (xsizelbl + ObjFontSize/2);
            
                        ObjectSetInteger(ObjChartID, name, OBJPROP_XDISTANCE, x);
                        ObjectSetInteger(ObjChartID, name, OBJPROP_YDISTANCE, ObjY);
                        ObjectSetString(ObjChartID, name, OBJPROP_TEXT, (string)text);
                    }
                    
                    ChartRedraw();
                }
            
                initialized = true;
            }
            
            _callback_(1);
        }
    };


    //------------------------------------------------------------------------------------------------------------------------

    // "Relative Strength Index" model
    class MDLIC_indicators_iRSI
    {
        public: /* Input Parameters */
        int RSIperiod;
        ENUM_APPLIED_PRICE AppliedPrice;
        string Symbol;
        ENUM_TIMEFRAMES Period;
        int Shift;
        virtual void _callback_(int r) {return;}

        public: /* Constructor */
        MDLIC_indicators_iRSI()
        {
            RSIperiod = (int)14;
            AppliedPrice = (ENUM_APPLIED_PRICE)PRICE_CLOSE;
            Symbol = (string)CurrentSymbol();
            Period = (ENUM_TIMEFRAMES)CurrentTimeframe();
            Shift = (int)0;
        }

        public: /* The main method */
        double _execute_()
        {
            return iRSI(Symbol, Period, RSIperiod, AppliedPrice, Shift + FXD_MORE_SHIFT);
        }
    };

    // "Numeric" model
    class MDLIC_value_value
    {
        public: /* Input Parameters */
        double Value;
        virtual void _callback_(int r) {return;}

        public: /* Constructor */
        MDLIC_value_value()
        {
            Value = (double)1.0;
        }

        public: /* The main method */
        double _execute_()
        {
            return Value;
        }
    };

    // "Time" model
    class MDLIC_value_time
    {
        public: /* Input Parameters */
        int ModeTime;
        int TimeSource;
        string TimeStamp;
        int TimeCandleID;
        string TimeMarket;
        ENUM_TIMEFRAMES TimeCandleTimeframe;
        int TimeComponentYear;
        int TimeComponentMonth;
        double TimeComponentDay;
        double TimeComponentHour;
        double TimeComponentMinute;
        int TimeComponentSecond;
        datetime TimeValue;
        int ModeTimeShift;
        int TimeShiftYears;
        int TimeShiftMonths;
        int TimeShiftWeeks;
        double TimeShiftDays;
        double TimeShiftHours;
        double TimeShiftMinutes;
        int TimeShiftSeconds;
        bool TimeSkipWeekdays;
        /* Static Parameters */
        datetime retval;
        datetime retval0;
        datetime Time[];
        virtual void _callback_(int r) {return;}

        public: /* Constructor */
        MDLIC_value_time()
        {
            ModeTime = (int)0;
            TimeSource = (int)0;
            TimeStamp = (string)"00:00";
            TimeCandleID = (int)1;
            TimeMarket = (string)"";
            TimeCandleTimeframe = (ENUM_TIMEFRAMES)0;
            TimeComponentYear = (int)0;
            TimeComponentMonth = (int)0;
            TimeComponentDay = (double)0.0;
            TimeComponentHour = (double)12.0;
            TimeComponentMinute = (double)0.0;
            TimeComponentSecond = (int)0;
            TimeValue = (datetime)0;
            ModeTimeShift = (int)0;
            TimeShiftYears = (int)0;
            TimeShiftMonths = (int)0;
            TimeShiftWeeks = (int)0;
            TimeShiftDays = (double)0.0;
            TimeShiftHours = (double)0.0;
            TimeShiftMinutes = (double)0.0;
            TimeShiftSeconds = (int)0;
            TimeSkipWeekdays = (bool)false;
            /* Static Parameters (initial value) */
            retval =  0;
            retval0 =  0;
        }

        public: /* The main method */
        datetime _execute_()
        {
            // this is static for speed reasons
            
            if (TimeMarket == "") TimeMarket = Symbol();
            
            if (ModeTime == 0)
            {
                    if (TimeSource == 0) {retval = TimeCurrent();}
                else if (TimeSource == 1) {retval = TimeLocal() + (TimeCurrent() - TimeLocal());}
                else if (TimeSource == 2) {retval = TimeGMT() + (TimeCurrent() - TimeGMT());}
            }
            else if (ModeTime == 1)
            {
                retval  = StringToTime(TimeStamp);
                retval0 = retval;
            }
            else if (ModeTime==2)
            {
                retval = TimeFromComponents(TimeSource, TimeComponentYear, TimeComponentMonth, TimeComponentDay, TimeComponentHour, TimeComponentMinute, TimeComponentSecond);
            }
            else if (ModeTime == 3)
            {
                ArraySetAsSeries(Time,true);
                CopyTime(TimeMarket,TimeCandleTimeframe,TimeCandleID,1,Time);
                retval = Time[0];
            }
            else if (ModeTime == 4)
            {
                retval = TimeValue;
            }
            
            if (ModeTimeShift > 0)
            {
                int sh = 1;
            
                if (ModeTimeShift == 1) {sh = -1;}
            
                if (TimeShiftYears > 0 || TimeShiftMonths > 0)
                {
                    int year = 0, month = 0, week = 0, day = 0, hour = 0, minute = 0, second = 0;
            
                    if (ModeTime == 3)
                    {
                        year   = TimeComponentYear;
                        month  = TimeComponentYear;
                        day    = (int)MathFloor(TimeComponentDay);
                        hour   = (int)(MathFloor(TimeComponentHour) + (24 * (TimeComponentDay - MathFloor(TimeComponentDay))));
                        minute = (int)(MathFloor(TimeComponentMinute) + (60 * (TimeComponentHour - MathFloor(TimeComponentHour))));
                        second = (int)(TimeComponentSecond + (60 * (TimeComponentMinute - MathFloor(TimeComponentMinute))));
                    }
                    else {
                        year   = TimeYear(retval);
                        month  = TimeMonth(retval);
                        day    = TimeDay(retval);
                        hour   = TimeHour(retval);
                        minute = TimeMinute(retval);
                        second = TimeSeconds(retval);
                    }
            
                    year  = year + TimeShiftYears * sh;
                    month = month + TimeShiftMonths * sh;
            
                    if (month < 0) {month = 12 - month;}
                    else if (month > 12) {month = month - 12;}
            
                    retval = StringToTime(IntegerToString(year)+"."+IntegerToString(month)+"."+IntegerToString(day)+" "+IntegerToString(hour)+":"+IntegerToString(minute)+":"+IntegerToString(second));
                }
            
                retval = retval + (sh * ((604800 * TimeShiftWeeks) + SecondsFromComponents(TimeShiftDays, TimeShiftHours, TimeShiftMinutes, TimeShiftSeconds)));
            
                if (TimeSkipWeekdays == true)
                {
                    int weekday = TimeDayOfWeek(retval);
            
                    if (sh > 0) { // forward
                            if (weekday == 0) {retval = retval + 86400;}
                        else if (weekday == 6) {retval = retval + 172800;}
                    }
                    else if (sh < 0) { // back
                            if (weekday == 0) {retval = retval - 172800;}
                        else if (weekday == 6) {retval = retval - 86400;}
                    }
                }
            }
            
            
            return (datetime)retval;
        }
    };

    // "Balance" model
    class MDLIC_account_AccountBalance
    {
        public: /* Input Parameters */
        virtual void _callback_(int r) {return;}

        public: /* Constructor */
        MDLIC_account_AccountBalance()
        {
        }

        public: /* The main method */
        double _execute_()
        {
            return NormalizeDouble(AccountInfoDouble(ACCOUNT_BALANCE), 2);
        }
    };

    // "Equity" model
    class MDLIC_account_AccountEquity
    {
        public: /* Input Parameters */
        virtual void _callback_(int r) {return;}

        public: /* Constructor */
        MDLIC_account_AccountEquity()
        {
        }

        public: /* The main method */
        double _execute_()
        {
            return NormalizeDouble(AccountInfoDouble(ACCOUNT_EQUITY), 2);
        }
    };

    // "Text" model
    class MDLIC_text_text
    {
        public: /* Input Parameters */
        string Text;
        virtual void _callback_(int r) {return;}

        public: /* Constructor */
        MDLIC_text_text()
        {
            Text = (string)"sample text";
        }

        public: /* The main method */
        string _execute_()
        {
            return Text;
        }
    };


    //------------------------------------------------------------------------------------------------------------------------

    // Block 1 (No trade/order(Buy/Sell))
    class Block0: public MDL_NoOrders<string,string,string,string,string>
    {

        public: /* Constructor */
        Block0() {
            __block_number = 0;
            __block_user_number = "1";
            _beforeExecuteEnabled = true;

            // Fill the list of outbound blocks
            int ___outbound_blocks[4] = {1,2,6,7};
            ArrayCopy(__outbound_blocks, ___outbound_blocks);
        }

        public: /* Callback & Run */
        virtual void _callback_(int value) {
            if (value == 1) {
                _blocks_[1].run(0);
                _blocks_[2].run(0);
                _blocks_[6].run(0);
                _blocks_[7].run(0);
            }
        }

        virtual void _beforeExecute_()
        {

            Symbol = (string)CurrentSymbol();
        }
    };

    // Block 2 (RSI&gt;50&nbsp;(Buy))
    class Block1: public MDL_Condition<MDLIC_indicators_iRSI,double,string,MDLIC_value_value,double,int>
    {

        public: /* Constructor */
        Block1() {
            __block_number = 1;
            __block_user_number = "2";


            // Fill the list of outbound blocks
            int ___outbound_blocks[1] = {3};
            ArrayCopy(__outbound_blocks, ___outbound_blocks);

            // IC input parameters
            Lo.Shift = 1;
            Ro.Value = adaptiveRSI.GetOptimalBuyLevel();
            // Block input parameters
            compare = "x>";
        }

        public: /* Custom methods */
        virtual double _Lo_() {
            Lo.RSIperiod = c::RSI_period;
            Lo.AppliedPrice = PRICE_CLOSE;
            Lo.Symbol = CurrentSymbol();
            Lo.Period = CurrentTimeframe();

            return Lo._execute_();
        }
        virtual double _Ro_() {return Ro._execute_();}

        public: /* Callback & Run */
        virtual void _callback_(int value) {
            if (value == 1) {
                _blocks_[3].run(1);
            }
        }
    };

    // Block 3 (RSI&gt;59&nbsp;(Buy))
    class Block2: public MDL_Condition<MDLIC_indicators_iRSI,double,string,MDLIC_value_value,double,int>
    {

        public: /* Constructor */
        Block2() {
            __block_number = 2;
            __block_user_number = "3";


            // Fill the list of outbound blocks
            int ___outbound_blocks[1] = {3};
            ArrayCopy(__outbound_blocks, ___outbound_blocks);

            // IC input parameters
            Lo.Shift = 1;
            Ro.Value = 59.0;
            // Block input parameters
            compare = "x>";
        }

        public: /* Custom methods */
        virtual double _Lo_() {
            Lo.RSIperiod = c::RSI_period;
            Lo.AppliedPrice = PRICE_CLOSE;
            Lo.Symbol = CurrentSymbol();
            Lo.Period = CurrentTimeframe();

            return Lo._execute_();
        }
        virtual double _Ro_() {return Ro._execute_();}

        public: /* Callback & Run */
        virtual void _callback_(int value) {
            if (value == 1) {
                _blocks_[3].run(2);
            }
        }
    };

    // Block 4 (OR)
    class Block3: public MDL_LogicalOR
    {

        public: /* Constructor */
        Block3() {
            __block_number = 3;
            __block_user_number = "4";


            // Fill the list of outbound blocks
            int ___outbound_blocks[1] = {4};
            ArrayCopy(__outbound_blocks, ___outbound_blocks);
        }

        public: /* Callback & Run */
        virtual void _callback_(int value) {
            if (value == 1) {
                _blocks_[4].run(3);
            }
        }
    };

    // Block 5 (Once per bar)
    class Block4: public MDL_OncePerBar<string,ENUM_TIMEFRAMES,int>
    {

        public: /* Constructor */
        Block4() {
            __block_number = 4;
            __block_user_number = "5";
            _beforeExecuteEnabled = true;

            // Fill the list of outbound blocks
            int ___outbound_blocks[1] = {5};
            ArrayCopy(__outbound_blocks, ___outbound_blocks);
        }

        public: /* Callback & Run */
        virtual void _callback_(int value) {
            if (value == 1) {
                _blocks_[5].run(4);
            }
        }

        virtual void _beforeExecute_()
        {

            Symbol = (string)CurrentSymbol();
            Period = (ENUM_TIMEFRAMES)CurrentTimeframe();
        }
    };

    // Block 6 (Buy now)
    class Block5: public MDL_BuyNow<string,string,string,double,double,double,double,double,MDLIC_value_value,double,double,double,int,double,double,double,double,double,int,int,double,bool,double,double,bool,double,string,bool,double,string,string,bool,double,string,double,double,double,MDLIC_value_value,double,MDLIC_value_value,double,MDLIC_value_value,double,string,double,double,double,MDLIC_value_value,double,MDLIC_value_value,double,MDLIC_value_value,double,string,int,int,int,MDLIC_value_time,datetime,ulong,string,color>
    {

        public: /* Constructor */
        Block5() {
            __block_number = 5;
            __block_user_number = "6";
            _beforeExecuteEnabled = true;

            // IC input parameters
            dVolumeSize.Value = 0.1;
            dpStopLoss.Value = 100.0;
            ddStopLoss.Value = 0.01;
            dpTakeProfit.Value = 100.0;
            ddTakeProfit.Value = 0.01;
            dExp.ModeTimeShift = 2;
            dExp.TimeShiftDays = 1.0;
            dExp.TimeSkipWeekdays = true;
            // Block input parameters
            VolumeMode = "balance";
            StopLossMode = "none";
            TakeProfitMode = "none";
        }

        public: /* Custom methods */
        virtual double _dVolumeSize_() {return dVolumeSize._execute_();}
        virtual double _dlStopLoss_() {return dlStopLoss._execute_();}
        virtual double _dpStopLoss_() {return dpStopLoss._execute_();}
        virtual double _ddStopLoss_() {return ddStopLoss._execute_();}
        virtual double _dlTakeProfit_() {return dlTakeProfit._execute_();}
        virtual double _dpTakeProfit_() {return dpTakeProfit._execute_();}
        virtual double _ddTakeProfit_() {return ddTakeProfit._execute_();}
        virtual datetime _dExp_() {return dExp._execute_();}

        public: /* Callback & Run */
        virtual void _callback_(int value) {
        }

        virtual void _beforeExecute_()
        {

            Symbol = (string)CurrentSymbol();
            VolumePercent = (double)c::Percent_Balance;
            MyComment = (string)c::MANSAMUSSA_2_0;
            ArrowColorBuy = (color)clrBlue;
        }
    };

    // Block 7 (RSI&lt;50&nbsp;(Sell))
    class Block6: public MDL_Condition<MDLIC_indicators_iRSI,double,string,MDLIC_value_value,double,int>
    {

        public: /* Constructor */
        Block6() {
            __block_number = 6;
            __block_user_number = "7";


            // Fill the list of outbound blocks
            int ___outbound_blocks[1] = {8};
            ArrayCopy(__outbound_blocks, ___outbound_blocks);

            // IC input parameters
            Lo.Shift = 1;
           Ro.Value = adaptiveRSI.GetOptimalSellLevel();
            // Block input parameters
            compare = "x<";
        }

        public: /* Custom methods */
        virtual double _Lo_() {
            Lo.RSIperiod = c::RSI_period;
            Lo.AppliedPrice = PRICE_CLOSE;
            Lo.Symbol = CurrentSymbol();
            Lo.Period = CurrentTimeframe();

            return Lo._execute_();
        }
        virtual double _Ro_() {return Ro._execute_();}

        public: /* Callback & Run */
        virtual void _callback_(int value) {
            if (value == 1) {
                _blocks_[8].run(6);
            }
        }
    };

    // Block 8 (RSI&lt;41&nbsp;(Sell))
    class Block7: public MDL_Condition<MDLIC_indicators_iRSI,double,string,MDLIC_value_value,double,int>
    {

        public: /* Constructor */
        Block7() {
            __block_number = 7;
            __block_user_number = "8";


            // Fill the list of outbound blocks
            int ___outbound_blocks[1] = {8};
            ArrayCopy(__outbound_blocks, ___outbound_blocks);

            // IC input parameters
            Lo.Shift = 1;
            Ro.Value = 41.0;
            // Block input parameters
            compare = "x<";
        }

        public: /* Custom methods */
        virtual double _Lo_() {
            Lo.RSIperiod = c::RSI_period;
            Lo.AppliedPrice = PRICE_CLOSE;
            Lo.Symbol = CurrentSymbol();
            Lo.Period = CurrentTimeframe();

            return Lo._execute_();
        }
        virtual double _Ro_() {return Ro._execute_();}

        public: /* Callback & Run */
        virtual void _callback_(int value) {
            if (value == 1) {
                _blocks_[8].run(7);
            }
        }
    };

    // Block 9 (OR)
    class Block8: public MDL_LogicalOR
    {

        public: /* Constructor */
        Block8() {
            __block_number = 8;
            __block_user_number = "9";

        }

        public: /* Callback & Run */
        virtual void _callback_(int value) {
        }
    };

    // Block 12 (If trade(Buy/Sell))
    class Block9: public MDL_IfOpenedOrders<string,string,string,string,string>
    {

        public: /* Constructor */
        Block9() {
            __block_number = 9;
            __block_user_number = "12";
            _beforeExecuteEnabled = true;

            // Fill the list of outbound blocks
            int ___outbound_blocks[1] = {10};
            ArrayCopy(__outbound_blocks, ___outbound_blocks);
        }

        public: /* Callback & Run */
        virtual void _callback_(int value) {
            if (value == 1) {
                _blocks_[10].run(9);
            }
        }

        virtual void _beforeExecute_()
        {

            Symbol = (string)CurrentSymbol();
        }
    };

    // Block 13 (Percent Profit)
    class Block10: public MDL_Formula_1<MDLIC_account_AccountBalance,double,string,MDLIC_value_value,double>
    {

        public: /* Constructor */
        Block10() {
            __block_number = 10;
            __block_user_number = "13";


            // Fill the list of outbound blocks
            int ___outbound_blocks[1] = {11};
            ArrayCopy(__outbound_blocks, ___outbound_blocks);
            // Block input parameters
            compare = "*";
        }

        public: /* Custom methods */
        virtual double _Lo_() {return Lo._execute_();}
        virtual double _Ro_() {
            Ro.Value = c::Percent_Profit;

            return Ro._execute_();
        }

        public: /* Callback & Run */
        virtual void _callback_(int value) {
            if (value == 1) {
                _blocks_[11].run(10);
            }
        }
    };

    // Block 14 (Check profit (unrealized))
    class Block11: public MDL_CheckUProfit<string,string,string,string,string,string,string,double,double,string,string,double,double>
    {

        public: /* Constructor */
        Block11() {
            __block_number = 11;
            __block_user_number = "14";
            _beforeExecuteEnabled = true;

            // Fill the list of outbound blocks
            int ___outbound_blocks[1] = {12};
            ArrayCopy(__outbound_blocks, ___outbound_blocks);
        }

        public: /* Callback & Run */
        virtual void _callback_(int value) {
            if (value == 1) {
                        // Trade is profitable - update adaptive levels
            if (OrderType() == OP_BUY) {
                adaptiveRSI.AddSuccessfulLevel(true, iRSI(OrderSymbol(), PERIOD_CURRENT, c::RSI_period, PRICE_CLOSE, 1));
            }
            else if (OrderType() == OP_SELL) {
                adaptiveRSI.AddSuccessfulLevel(false, iRSI(OrderSymbol(), PERIOD_CURRENT, c::RSI_period, PRICE_CLOSE, 1));
            }
                _blocks_[12].run(11);
            }
        }

        virtual void _beforeExecute_()
        {

            Symbol = (string)CurrentSymbol();
            ProfitAmount = (double)v::Percentage_profit_BS;
        }
    };

    // Block 15 (Close trades(Buy/Sell))
    class Block12: public MDL_CloseOpened<string,string,string,string,string,int,ulong,color>
    {

        public: /* Constructor */
        Block12() {
            __block_number = 12;
            __block_user_number = "15";
            _beforeExecuteEnabled = true;
        }

        public: /* Callback & Run */
        virtual void _callback_(int value) {
        }

        virtual void _beforeExecute_()
        {

            Symbol = (string)CurrentSymbol();
            ArrowColor = (color)clrDeepPink;
        }
    };

    // Block 16 (If trade(Buy/Sell))
    class Block13: public MDL_IfOpenedOrders<string,string,string,string,string>
    {

        public: /* Constructor */
        Block13() {
            __block_number = 13;
            __block_user_number = "16";
            _beforeExecuteEnabled = true;

            // Fill the list of outbound blocks
            int ___outbound_blocks[1] = {14};
            ArrayCopy(__outbound_blocks, ___outbound_blocks);
        }

        public: /* Callback & Run */
        virtual void _callback_(int value) {
            if (value == 1) {
                _blocks_[14].run(13);
            }
        }

        virtual void _beforeExecute_()
        {

            Symbol = (string)CurrentSymbol();
        }
    };

    // Block 17 (Percent loss)
    class Block14: public MDL_Formula_2<MDLIC_account_AccountBalance,double,string,MDLIC_value_value,double>
    {

        public: /* Constructor */
        Block14() {
            __block_number = 14;
            __block_user_number = "17";


            // Fill the list of outbound blocks
            int ___outbound_blocks[1] = {15};
            ArrayCopy(__outbound_blocks, ___outbound_blocks);
            // Block input parameters
            compare = "*";
        }

        public: /* Custom methods */
        virtual double _Lo_() {return Lo._execute_();}
        virtual double _Ro_() {
            Ro.Value = c::Percent_loss;

            double value = (double)Ro._execute_();
            value = value*-1; // Adjust the value
            return value;
        }

        public: /* Callback & Run */
        virtual void _callback_(int value) {
            if (value == 1) {
                _blocks_[15].run(14);
            }
        }
    };

    // Block 18 (Check profit (unrealized))
    class Block15: public MDL_CheckUProfit<string,string,string,string,string,string,string,double,double,string,string,double,double>
    {

        public: /* Constructor */
        Block15() {
            __block_number = 15;
            __block_user_number = "18";
            _beforeExecuteEnabled = true;

            // Fill the list of outbound blocks
            int ___outbound_blocks[1] = {16};
            ArrayCopy(__outbound_blocks, ___outbound_blocks);
            // Block input parameters
            Compare = "<";
        }

        public: /* Callback & Run */
        virtual void _callback_(int value) {
            if (value == 1) {
                _blocks_[16].run(15);
            }
        }

        virtual void _beforeExecute_()
        {

            Symbol = (string)CurrentSymbol();
            ProfitAmount = (double)v::Percentage_Loss_BS;
        }
    };

    // Block 19 (Close trades(Buy/Sell))
    class Block16: public MDL_CloseOpened<string,string,string,string,string,int,ulong,color>
    {

        public: /* Constructor */
        Block16() {
            __block_number = 16;
            __block_user_number = "19";
            _beforeExecuteEnabled = true;
        }

        public: /* Callback & Run */
        virtual void _callback_(int value) {
        }

        virtual void _beforeExecute_()
        {

            Symbol = (string)CurrentSymbol();
            ArrowColor = (color)clrDeepPink;
        }
    };

    // Block 20 (Pass)
    class Block17: public MDL_Pass
    {

        public: /* Constructor */
        Block17() {
            __block_number = 17;
            __block_user_number = "20";


            // Fill the list of outbound blocks
            int ___outbound_blocks[1] = {18};
            ArrayCopy(__outbound_blocks, ___outbound_blocks);
        }

        public: /* Callback & Run */
        virtual void _callback_(int value) {
            if (value == 1) {
                _blocks_[18].run(17);
            }
        }
    };

    // Block 21 (Comment)
    class Block18: public MDL_CommentEx<string,string,int,int,int,string,color,int,string,color,int,string,color,int,string,MDLIC_account_AccountBalance,double,int,int,string,MDLIC_account_AccountEquity,double,int,int,string,MDLIC_value_value,double,int,int,string,MDLIC_value_value,double,int,int,string,MDLIC_value_value,double,int,int,string,MDLIC_value_value,double,int,int,string,MDLIC_text_text,string,int,int,string,MDLIC_text_text,string,int,int>
    {

        public: /* Constructor */
        Block18() {
            __block_number = 18;
            __block_user_number = "21";
            _beforeExecuteEnabled = true;

            // IC input parameters
            Value7.Text = "";
            Value8.Text = "";
            // Block input parameters
            Label1 = "Balance";
            FormatNumber1 = 2;
            Label2 = "Equity";
            FormatNumber2 = 2;
            Label3 = "(%) Profit";
            Label4 = "($) profits";
            FormatNumber4 = 2;
            Label5 = "(%) loss";
            Label6 = "($) loss";
            FormatNumber6 = 2;
        }

        public: /* Custom methods */
        virtual double _Value1_() {return Value1._execute_();}
        virtual double _Value2_() {return Value2._execute_();}
        virtual double _Value3_() {
            Value3.Value = c::Percent_Profit;

            return Value3._execute_();
        }
        virtual double _Value4_() {
            Value4.Value = v::Percentage_profit_BS;

            return Value4._execute_();
        }
        virtual double _Value5_() {
            Value5.Value = c::Percent_loss;

            return Value5._execute_();
        }
        virtual double _Value6_() {
            Value6.Value = v::Percentage_Loss_BS;

            return Value6._execute_();
        }
        virtual string _Value7_() {return Value7._execute_();}
        virtual string _Value8_() {return Value8._execute_();}

        public: /* Callback & Run */
        virtual void _callback_(int value) {
        }

        virtual void _beforeExecute_()
        {

            /* Inputs, modified into the code must be set here every time */
            ObjY = 24;
            Title = (string)c::MANSAMUSSA_2_0;
            ObjCorner = (int)CORNER_RIGHT_UPPER;
            ObjTitleFontColor = (color)clrGold;
            ObjLabelsFontColor = (color)clrDarkGray;
            ObjFontColor = (color)clrWhite;
            FormatTime1 = (int)EMPTY_VALUE;
            FormatTime2 = (int)EMPTY_VALUE;
            FormatNumber3 = (int)EMPTY_VALUE;
            FormatTime3 = (int)EMPTY_VALUE;
            FormatTime4 = (int)EMPTY_VALUE;
            FormatNumber5 = (int)EMPTY_VALUE;
            FormatTime5 = (int)EMPTY_VALUE;
            FormatTime6 = (int)EMPTY_VALUE;
            FormatNumber7 = (int)EMPTY_VALUE;
            FormatTime7 = (int)EMPTY_VALUE;
            FormatNumber8 = (int)EMPTY_VALUE;
            FormatTime8 = (int)EMPTY_VALUE;
        }
    };


    /************************************************************************************************************************/
    // +------------------------------------------------------------------------------------------------------------------+ //
    // |                                                   Functions                                                      | //
    // |                                 System and Custom functions used in the program                                  | //
    // +------------------------------------------------------------------------------------------------------------------+ //
    /************************************************************************************************************************/


    double AccountBalanceAtStart()
    {
        // This function MUST be run once at pogram's start
        static double memory = 0;

        if (memory == 0)
        {
            memory = NormalizeDouble(AccountInfoDouble(ACCOUNT_BALANCE), 2);
        }

        return memory;
    }

    double AlignLots(string symbol, double lots, double lowerlots = 0.0, double upperlots = 0.0)
    {
        double LotStep = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
        double LotSize = SymbolInfoDouble(symbol, SYMBOL_TRADE_CONTRACT_SIZE);
        double MinLots = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
        double MaxLots = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);

        if (LotStep > MinLots) MinLots = LotStep;

        if (lots == EMPTY_VALUE) {lots = 0.0;}

        lots = MathRound(lots / LotStep) * LotStep;

        if (lots < MinLots) {lots = MinLots;}
        if (lots > MaxLots) {lots = MaxLots;}

        if (lowerlots > 0.0)
        {
            lowerlots = MathRound(lowerlots / LotStep) * LotStep;
            if (lots < lowerlots) {lots = lowerlots;}
        }

        if (upperlots > 0.0)
        {
            upperlots = MathRound(upperlots / LotStep) * LotStep;
            if (lots > upperlots) {lots = upperlots;}
        }

        return lots;
    }

    double AlignStopLoss(
        string symbol,
        int type,
        double price,
        double slo = 0.0, // original sl, used when modifying
        double sll = 0.0,
        double slp = 0.0,
        bool consider_freezelevel = false
        )
    {
        double sl = 0.0;

        if (MathAbs(sll) == EMPTY_VALUE) {sll = 0.0;}
        if (MathAbs(slp) == EMPTY_VALUE) {slp = 0.0;}

        if (sll == 0.0 && slp == 0.0)
        {
            return 0.0;
        }

        if (price <= 0.0)
        {
            Print(__FUNCTION__ + " error: No price entered");

            return -1;
        }

        double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
        int digits   = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
        slp          = slp * PipValue(symbol) * point;

        //-- buy-sell identifier ---------------------------------------------
        int bs = 1;

        if (
            type == OP_SELL
            || type == OP_SELLSTOP
            || type == OP_SELLLIMIT

            )
        {
            bs = -1;
        }

        //-- prices that will be used ----------------------------------------
        double askbid = price;
        double bidask = price;
        
        if (type < 2)
        {
            double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
            double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
            
            askbid = ask;
            bidask = bid;

            if (bs < 0)
            {
            askbid = bid;
            bidask = ask;
            }
        }

        //-- build sl level -------------------------------------------------- 
        if (sll == 0.0 && slp != 0.0) {sll = price;}

        if (sll > 0.0) {sl = sll - slp * bs;}

        if (sl < 0.0)
        {
            return -1;
        }

        sl  = NormalizeDouble(sl, digits);
        slo = NormalizeDouble(slo, digits);

        if (sl == slo)
        {
            return sl;
        }

        //-- build limit levels ----------------------------------------------
        double minstops = (double)SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL);

        if (consider_freezelevel == true)
        {
            double freezelevel = (double)SymbolInfoInteger(symbol, SYMBOL_TRADE_FREEZE_LEVEL);

            if (freezelevel > minstops) {minstops = freezelevel;}
        }

        minstops = NormalizeDouble(minstops * point,digits);

        double sllimit = bidask - minstops * bs; // SL min price level

        //-- check and align sl, print errors --------------------------------
        //-- do not do it when the stop is the same as the original
        if (sl > 0.0 && sl != slo)
        {
            if ((bs > 0 && sl > askbid) || (bs < 0 && sl < askbid))
            {
                string abstr = "";

                if (bs > 0) {abstr = "Bid";} else {abstr = "Ask";}

                Print(
                    "Error: Invalid SL requested (",
                    DoubleToStr(sl, digits),
                    " for ", abstr, " price ",
                    bidask,
                    ")"
                );

                return -1;
            }
            else if ((bs > 0 && sl > sllimit) || (bs < 0 && sl < sllimit))
            {
                if (USE_VIRTUAL_STOPS)
                {
                    return sl;
                }

                Print(
                    "Warning: Too short SL requested (",
                    DoubleToStr(sl, digits),
                    " or ",
                    DoubleToStr(MathAbs(sl - askbid) / point, 0),
                    " points), minimum will be taken (",
                    DoubleToStr(sllimit, digits),
                    " or ",
                    DoubleToStr(MathAbs(askbid - sllimit) / point, 0),
                    " points)"
                );

                sl = sllimit;

                return sl;
            }
        }

        // align by the ticksize
        double ticksize = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
        sl = MathRound(sl / ticksize) * ticksize;

        return sl;
    }

    double AlignTakeProfit(
        string symbol,
        int type,
        double price,
        double tpo = 0.0, // original tp, used when modifying
        double tpl = 0.0,
        double tpp = 0.0,
        bool consider_freezelevel = false
        )
    {
        double tp = 0.0;
        
        if (MathAbs(tpl) == EMPTY_VALUE) {tpl = 0.0;}
        if (MathAbs(tpp) == EMPTY_VALUE) {tpp = 0.0;}

        if (tpl == 0.0 && tpp == 0.0)
        {
            return 0.0;
        }

        if (price <= 0.0)
        {
            Print(__FUNCTION__ + " error: No price entered");

            return -1;
        }

        double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
        int digits   = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
        tpp          = tpp * PipValue(symbol) * point;
        
        //-- buy-sell identifier ---------------------------------------------
        int bs = 1;

        if (
            type == OP_SELL
            || type == OP_SELLSTOP
            || type == OP_SELLLIMIT

            )
        {
            bs = -1;
        }
        
        //-- prices that will be used ----------------------------------------
        double askbid = price;
        double bidask = price;
        
        if (type < 2)
        {
            double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
            double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
            
            askbid = ask;
            bidask = bid;

            if (bs < 0)
            {
            askbid = bid;
            bidask = ask;
            }
        }
        
        //-- build tp level --------------------------------------------------- 
        if (tpl == 0.0 && tpp != 0.0) {tpl = price;}

        if (tpl > 0.0) {tp = tpl + tpp * bs;}
        
        if (tp < 0.0)
        {
            return -1;
        }

        tp  = NormalizeDouble(tp, digits);
        tpo = NormalizeDouble(tpo, digits);

        if (tp == tpo)
        {
            return tp;
        }
        
        //-- build limit levels ----------------------------------------------
        double minstops = (double)SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL);

        if (consider_freezelevel == true)
        {
            double freezelevel = (double)SymbolInfoInteger(symbol, SYMBOL_TRADE_FREEZE_LEVEL);

            if (freezelevel > minstops) {minstops = freezelevel;}
        }

        minstops = NormalizeDouble(minstops * point,digits);
        
        double tplimit = bidask + minstops * bs; // TP min price level
        
        //-- check and align tp, print errors --------------------------------
        //-- do not do it when the stop is the same as the original
        if (tp > 0.0 && tp != tpo)
        {
            if ((bs > 0 && tp < bidask) || (bs < 0 && tp > bidask))
            {
                string abstr = "";

                if (bs > 0) {abstr = "Bid";} else {abstr = "Ask";}

                Print(
                    "Error: Invalid TP requested (",
                    DoubleToStr(tp, digits),
                    " for ", abstr, " price ",
                    bidask,
                    ")"
                );

                return -1;
            }
            else if ((bs > 0 && tp < tplimit) || (bs < 0 && tp > tplimit))
            {
                if (USE_VIRTUAL_STOPS)
                {
                    return tp;
                }

                Print(
                    "Warning: Too short TP requested (",
                    DoubleToStr(tp, digits),
                    " or ",
                    DoubleToStr(MathAbs(tp - askbid) / point, 0),
                    " points), minimum will be taken (",
                    DoubleToStr(tplimit, digits),
                    " or ",
                    DoubleToStr(MathAbs(askbid - tplimit) / point, 0),
                    " points)"
                );

                tp = tplimit;

                return tp;
            }
        }
        
        // align by the ticksize
        double ticksize = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
        tp = MathRound(tp / ticksize) * ticksize;
        
        return tp;
    }

    template<typename T>
    bool ArrayEnsureValue(T &array[], T value)
    {
        int size   = ArraySize(array);
        
        if (size > 0)
        {
            if (InArray(array, value))
            {
                // value found -> exit
                return false; // no value added
            }
        }
        
        // value does not exists -> add it
        ArrayResize(array, size+1);
        array[size] = value;
            
        return true; // value added
    }

    template<typename T>
    int ArraySearch(T &array[], T value)
    {
        int index = -1;
        int size  = ArraySize(array);

        for (int i = 0; i < size; i++)
        {
            if (array[i] == value)
            {
                index = i;
                break;
            }  
        }

    return index;
    }

    template<typename T>
    bool ArrayStripKey(T &array[], int key)
    {
        int x    = 0;
        int size = ArraySize(array);

        for (int i=0; i<size; i++)
        {
            if (i != key)
            {
                array[x] = array[i];
                x++;
            }
        }

        if (x < size)
        {
            ArrayResize(array, x);
            
            return true; // stripped
        }

        return false; // not stripped
    }

    template<typename T>
    bool ArrayStripValue(T &array[], T value)
    {
        int x    = 0;
        int size = ArraySize(array);

        for (int i=0; i<size; i++)
        {
            if (array[i] != value)
            {
                array[x] = array[i];
                x++;
            }
        }

        if (x < size)
        {
            ArrayResize(array, x);
            
            return true; // stripped
        }

        return false; // not stripped
    }

    double Bet1326(
        string group,
        string symbol,
        int pool,
        double initialLots,
        bool reverse = false
    ) {  
        double info[];
        GetBetTradesInfo(info, group, symbol, pool, false);

        double lots         = info[0];
        double profitOrLoss = info[1]; // 0 - unknown, 1 - profit, -1 - loss

        //-- 1-3-2-6 Logic
        double minLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);

        if (initialLots < minLot)
        {
            initialLots = minLot;  
        }

        if (lots == 0)
        {
            lots = initialLots;
        }
        else
        {
            if (
                (reverse == false && profitOrLoss == 1)
                || (reverse == true && profitOrLoss == -1)
            ) {
                double div = lots / initialLots;

                    if (div < 1.5) {lots = initialLots * 3;}
                else if (div < 2.5) {lots = initialLots * 6;}
                else if (div < 3.5) {lots = initialLots * 2;}
                else {lots = initialLots;}
            }
            else
            {
                lots = initialLots;
            }
        }

        return lots;
    }

    double BetDalembert(
        string group,
        string symbol,
        int pool,
        double initialLots,
        double reverse = false
    ) {  
        double info[];
        GetBetTradesInfo(info, group, symbol, pool, false);

        double lots         = info[0];
        double profitOrLoss = info[1]; // 0 - unknown, 1 - profit, -1 - loss

        //-- Dalembert Logic
        double minLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);

        if (initialLots < minLot)
        {
            initialLots = minLot;  
        }

        if (lots == 0)
        {
            lots = initialLots;
        }
        else
        {
            if (
                (reverse == 0 && profitOrLoss == 1)
                || (reverse == 1 && profitOrLoss == -1)
            ) {
                lots = lots - initialLots;
                if (lots < initialLots) {lots = initialLots;}
            }
            else
            {
                lots = lots + initialLots;
            }
        }

        return lots;
    }

    double BetFibonacci(
        string group,
        string symbol,
        int pool,
        double initialLots
    ) {
        double info[];
        GetBetTradesInfo(info, group, symbol, pool, false);

        double lots         = info[0];
        double profitOrLoss = info[1]; // 0 - unknown, 1 - profit, -1 - loss

        //-- Fibonacci Logic
        double minLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);

        if (initialLots < minLot)
        {
            initialLots = minLot;  
        }

        if (lots == 0)
        {
            lots = initialLots;
        }
        else
        {  
            int fibo1 = 1;
            int fibo2 = 0;
            int fibo3 = 0;
            int fibo4 = 0;
            double div = lots / initialLots;

            if (div <= 0) {div = 1;}

            while (true)
            {
                fibo1 = fibo1 + fibo2;
                fibo3 = fibo2;
                fibo2 = fibo1 - fibo2;
                fibo4 = fibo2 - fibo3;

                if (fibo1 > NormalizeDouble(div, 2))
                {
                    break;
                }
            }

            if (profitOrLoss == 1)
            {
                if (fibo4 <= 0) {fibo4 = 1;}
                lots = initialLots * fibo4;
            }
            else
            {
                lots = initialLots * fibo1;
            }
        }

        lots = NormalizeDouble(lots, 2);

        return lots;
    }

    double BetLabouchere(
        string group,
        string symbol,
        int pool,
        double initialLots,
        string listOfNumbers,
        double reverse = false
    ) {
        double info[];
        GetBetTradesInfo(info, group, symbol, pool, false);

        double lots         = info[0];
        double profitOrLoss = info[1]; // 0 - unknown, 1 - profit, -1 - loss

        //-- Labouchere Logic
        static string memGroup[];
        static string memList[];
        static long memTicket[];

        int startAgain = false;

        //- get the list of numbers as it is stored in the memory, or store it
        int id = ArraySearch(memGroup, group);

        if (id == -1)
        {
            startAgain = true;

            if (listOfNumbers == "") {listOfNumbers = "1";}

            id = ArraySize(memGroup);

            ArrayResize(memGroup, id+1, id+1);
            ArrayResize(memList, id+1, id+1);
            ArrayResize(memTicket, id+1, id+1);

            memGroup[id] = group;
            memList[id]  = listOfNumbers;
        }

        if (memTicket[id] == (long)OrderTicket())
        {
            // the last known ticket (memTicket[id]) should be different than OderTicket() normally
            // when failed to create a new trade - the last ticket remains the same
            // so we need to reset
            memList[id] = listOfNumbers;
        }

        memTicket[id] = (long)OrderTicket();

        //- now turn the string into integer array
        int list[];
        string listS[];

        StringExplode(",", memList[id], listS);
        ArrayResize(list, ArraySize(listS));

        for (int s = 0; s < ArraySize(listS); s++)
        {
            list[s] = (int)StringToInteger(StringTrim(listS[s]));  
        }

        //-- 
        int size = ArraySize(list);

        double minLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);

        if (initialLots < minLot)
        {
            initialLots = minLot;  
        }

        if (lots == 0)
        {
            startAgain = true;
        }

        if (startAgain == true)
        {
            if (size == 1)
            {
                lots = initialLots * list[0];
            }
            else {
                lots = initialLots * (list[0] + list[size-1]);
            }
        }
        else 
        {
            if (
                (reverse == 0 && profitOrLoss == 1)
                || (reverse == 1 && profitOrLoss == -1)
            ) {
                size = size - 2;
                
                if (size < 0) {
                    size = 0;
                }
                
                if (size == 0) {
                    // Set the initial list of numbers
                    StringExplode(",", listOfNumbers, listS);
                    ArrayResize(list, ArraySize(listS));
                
                    for (int s = 0; s < ArraySize(listS); s++)
                    {
                        list[s] = (int)StringToInteger(StringTrim(listS[s]));  
                    }
                    
                    size = ArraySize(list);
                }
                else {
                    // Cancel the first and the last number in the list
                    // shift array 1 step left
                    for (int pos = 0; pos < ArraySize(list) - 1; pos++) {
                        list[pos] = list[pos+1];
                    }
                    
                    ArrayResize(list, size);
                }
                
                int rightNum = (size > 1) ? list[size - 1] : 0;
                lots = initialLots * (list[0] + rightNum);

                if (lots < initialLots) {lots = initialLots;}
            }
            else
            {
                size = size + 1;
                ArrayResize(list, size);
                
                int rightNum = (size > 2) ? list[size - 2] : 0;

                list[size - 1] = list[0] + rightNum;
                lots       = initialLots * (list[0] + list[size - 1]);

                if (lots < initialLots) {lots = initialLots;}
            }
        }

        Print("Labouchere (for group "
            + (string)id
            + ") current list of numbers: "
            + StringImplode(",", list)
        );

        size=ArraySize(list);

        if (size == 0)
        {
            ArrayStripKey(memGroup, id);
            ArrayStripKey(memList, id);
            ArrayStripKey(memTicket, id);
        }
        else {
            memList[id] = StringImplode(",", list);
        }

        return lots;
    }

    double BetMartingale(
        string group,
        string symbol,
        int pool,
        double initialLots,
        double multiplyOnLoss,
        double multiplyOnProfit,
        double addOnLoss,
        double addOnProfit,
        int resetOnLoss,
        int resetOnProfit
    ) {
        double info[];
        GetBetTradesInfo(info, group, symbol, pool, true);

        double lots         = info[0];
        double profitOrLoss = info[1]; // 0 - unknown, 1 - profit, -1 - loss
        double consecutive  = info[2];

        //-- Martingale Logic
        if (lots == 0)
        {
            lots = initialLots;
        }
        else
        {
            if (profitOrLoss == 1)
            {
                if (resetOnProfit > 0 && consecutive >= resetOnProfit)
                {
                    lots = initialLots;
                }
                else
                {
                    if (multiplyOnProfit <= 0)
                    {
                        multiplyOnProfit = 1;
                    }

                    lots = (lots * multiplyOnProfit) + addOnProfit;
                }
            }
            else
            {
                if (resetOnLoss > 0 && consecutive >= resetOnLoss)
                {
                    lots = initialLots;  
                }
                else
                {
                    if (multiplyOnLoss <= 0)
                    {
                        multiplyOnLoss = 1;
                    }

                    lots = (lots * multiplyOnLoss) + addOnLoss;
                }
            }
        }

        return lots;
    }

    double BetSequence(
        string group,
        string symbol,
        int pool,
        double initialLots,
        string sequenceOnLoss,
        string sequenceOnProfit,
        bool reverse = false
    ) {  
        double info[];
        GetBetTradesInfo(info, group, symbol, pool, false);

        double lots         = info[0];
        double profitOrLoss = info[1]; // 0 - unknown, 1 - profit, -1 - loss

        //-- Sequence stuff
        static string memGroup[];
        static string memLossList[];
        static string memProfitList[];
        static long memTicket[];

        //- get the list of numbers as it is stored in the memory, or store it
        int id = ArraySearch(memGroup, group);

        if (id == -1)
        {
            if (sequenceOnLoss == "") {sequenceOnLoss = "1";}

            if (sequenceOnProfit == "") {sequenceOnProfit = "1";}

            id = ArraySize(memGroup);

            ArrayResize(memGroup, id+1, id+1);
            ArrayResize(memLossList, id+1, id+1);
            ArrayResize(memProfitList, id+1, id+1);
            ArrayResize(memTicket, id+1, id+1);

            memGroup[id]      = group;
            memLossList[id]   = sequenceOnLoss;
            memProfitList[id] = sequenceOnProfit;
        }

        bool lossReset   = false;
        bool profitReset = false;

        if (profitOrLoss == -1 && memLossList[id] == "")
        {
            lossReset         = true;
            memProfitList[id] = "";
        }

        if (profitOrLoss == 1 && memProfitList[id] == "")
        {
            profitReset     = true;
            memLossList[id] = "";
        }

        if (profitOrLoss == 1 || memLossList[id] == "")
        {
            memLossList[id] = sequenceOnLoss;

            if (lossReset) {
                memLossList[id] = "1," + memLossList[id];
            }
        }

        if (profitOrLoss == -1 || memProfitList[id] == "")
        {
            memProfitList[id] = sequenceOnProfit;

            if (profitReset) {
                memProfitList[id] = "1," + memProfitList[id];
            }
        }

        if (memTicket[id] == (long)OrderTicket())
        {
            // Normally the last known ticket (memTicket[id]) should be different than OderTicket()
            // when failed to create a new trade, the last ticket remains the same
            // so we need to reset
            memLossList[id]   = sequenceOnLoss;
            memProfitList[id] = sequenceOnProfit;
        }

        memTicket[id] = (long)OrderTicket();

        //- now turn the string into integer array
        int s = 0;
        double listLoss[];
        double listProfit[];
        string listS[];

        StringExplode(",", memLossList[id], listS);
        ArrayResize(listLoss, ArraySize(listS), ArraySize(listS));

        for (s = 0; s < ArraySize(listS); s++)
        {
            listLoss[s] = (double)StringToDouble(StringTrim(listS[s]));  
        }

        StringExplode(",", memProfitList[id], listS);
        ArrayResize(listProfit, ArraySize(listS), ArraySize(listS));

        for (s = 0; s < ArraySize(listS); s++)
        {
            listProfit[s] = (double)StringToDouble(StringTrim(listS[s]));  
        }

        //--
        double minLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);

        if (initialLots < minLot)
        {
            initialLots = minLot;  
        }

        if (lots == 0)
        {
            lots = initialLots;
        }
        else
        {
            if (
                (reverse == false && profitOrLoss ==1)
                || (reverse == true && profitOrLoss == -1)
            ) {
                lots = initialLots * listProfit[0];

                // shift array 1 step left
                int size = ArraySize(listProfit);

                for(int pos = 0; pos < size-1; pos++)
                {
                    listProfit[pos] = listProfit[pos+1];
                }

                if (size > 0)
                {
                    ArrayResize(listProfit, size-1, size-1);
                    memProfitList[id] = StringImplode(",", listProfit);
                }
            }
            else
            {
                lots = initialLots * listLoss[0];

                // shift array 1 step left
                int size = ArraySize(listLoss);

                for(int pos = 0; pos < size-1; pos++)
                {
                    listLoss[pos] = listLoss[pos+1];
                }

                if (size > 0)
                {
                    ArrayResize(listLoss, size-1, size-1);
                    memLossList[id] = StringImplode(",", listLoss);
                }
            }
        }

        return lots;
    }

    int BuyNow(
        string symbol,
        double lots,
        double sll,
        double tpl,
        double slp,
        double tpp,
        double slippage = 0,
        int magic = 0,
        string comment = "",
        color arrowcolor = clrNONE,
        datetime expiration = 0
        )
    {
        return OrderCreate(
            symbol,
            OP_BUY,
            lots,
            0,
            sll,
            tpl,
            slp,
            tpp,
            slippage,
            magic,
            comment,
            arrowcolor,
            expiration
        );
    }

    int CheckForTradingError(int error_code=-1, string msg_prefix="")
    {
    // return 0 -> no error
    // return 1 -> overcomable error
    // return 2 -> fatal error
    
    if (error_code<0) {
        error_code=GetLastError();  
    }
    
    int retval=0;
    static int tryouts=0;
    
    //-- error check -----------------------------------------------------
    switch(error_code)
    {
        //-- no error
        case 0:
            retval=0;
            break;
        //-- overcomable errors
        case 1: // No error returned
            RefreshRates();
            retval=1;
            break;
        case 4: //ERR_SERVER_BUSY
            if (msg_prefix!="") {Print(StringConcatenate(msg_prefix,": ",ErrorMessage(error_code),". Retrying.."));}
            Sleep(1000);
            RefreshRates();
            retval=1;
            break;
        case 6: //ERR_NO_CONNECTION
            if (msg_prefix!="") {Print(StringConcatenate(msg_prefix,": ",ErrorMessage(error_code),". Retrying.."));}
            while(!IsConnected()) {Sleep(100);}
            while(IsTradeContextBusy()) {Sleep(50);}
            RefreshRates();
            retval=1;
            break;
        case 128: //ERR_TRADE_TIMEOUT
            if (msg_prefix!="") {Print(StringConcatenate(msg_prefix,": ",ErrorMessage(error_code),". Retrying.."));}
            RefreshRates();
            retval=1;
            break;
        case 129: //ERR_INVALID_PRICE
            if (msg_prefix!="") {Print(StringConcatenate(msg_prefix,": ",ErrorMessage(error_code),". Retrying.."));}
            if (!IsTesting()) {while(RefreshRates()==false) {Sleep(1);}}
            retval=1;
            break;
        case 130: //ERR_INVALID_STOPS
            if (msg_prefix!="") {Print(StringConcatenate(msg_prefix,": ",ErrorMessage(error_code),". Waiting for a new tick to retry.."));}
            if (!IsTesting()) {while(RefreshRates()==false) {Sleep(1);}}
            retval=1;
            break;
        case 135: //ERR_PRICE_CHANGED
            if (msg_prefix!="") {Print(StringConcatenate(msg_prefix,": ",ErrorMessage(error_code),". Waiting for a new tick to retry.."));}
            if (!IsTesting()) {while(RefreshRates()==false) {Sleep(1);}}
            retval=1;
            break;
        case 136: //ERR_OFF_QUOTES
            if (msg_prefix!="") {Print(StringConcatenate(msg_prefix,": ",ErrorMessage(error_code),". Waiting for a new tick to retry.."));}
            if (!IsTesting()) {while(RefreshRates()==false) {Sleep(1);}}
            retval=1;
            break;
        case 137: //ERR_BROKER_BUSY
            if (msg_prefix!="") {Print(StringConcatenate(msg_prefix,": ",ErrorMessage(error_code),". Retrying.."));}
            Sleep(1000);
            retval=1;
            break;
        case 138: //ERR_REQUOTE
            if (msg_prefix!="") {Print(StringConcatenate(msg_prefix,": ",ErrorMessage(error_code),". Waiting for a new tick to retry.."));}
            if (!IsTesting()) {while(RefreshRates()==false) {Sleep(1);}}
            retval=1;
            break;
        case 142: //This code should be processed in the same way as error 128.
            if (msg_prefix!="") {Print(StringConcatenate(msg_prefix,": ",ErrorMessage(error_code),". Retrying.."));}
            RefreshRates();
            retval=1;
            break;
        case 143: //This code should be processed in the same way as error 128.
            if (msg_prefix!="") {Print(StringConcatenate(msg_prefix,": ",ErrorMessage(error_code),". Retrying.."));}
            RefreshRates();
            retval=1;
            break;
        /*case 145: //ERR_TRADE_MODIFY_DENIED
            if (msg_prefix!="") {Print(StringConcatenate(msg_prefix,": ",ErrorMessage(error_code),". Waiting for a new tick to retry.."));}
            while(RefreshRates()==false) {Sleep(1);}
            return(1);
        */
        case 146: //ERR_TRADE_CONTEXT_BUSY
            if (msg_prefix!="") {Print(StringConcatenate(msg_prefix,": ",ErrorMessage(error_code),". Retrying.."));}
            while(IsTradeContextBusy()) {Sleep(50);}
            RefreshRates();
            retval=1;
            break;
        //-- critical errors
        default:
            if (msg_prefix!="") {Print(StringConcatenate(msg_prefix,": ",ErrorMessage(error_code)));}
            retval=2;
            break;
    }

    if (retval==0) {tryouts=0;}
    else if (retval==1) {
        tryouts++;
        if (tryouts>=10) {
            tryouts=0;
            retval=2;
        } else {
            Print("retry #"+(string)tryouts+" of 10");
        }
    }
    
    return(retval);
    }

    bool CloseTrade(ulong ticket, ulong slippage = 0, color arrowcolor = CLR_NONE)
    {
        bool success = false;
        bool exists  = false;
        
        for (int i = 0; i < OrdersTotal(); i++)
        {
            if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;

            if (OrderTicket() == ticket)
            {
                exists = true;
                break;
            }
        }

        if (exists == false)
        {
            return false;
        }

        while (true)
        {
            //-- wait if needed -----------------------------------------------
            WaitTradeContextIfBusy();

            //-- close --------------------------------------------------------
            success = OrderClose((int)ticket, OrderLots(), OrderClosePrice(), (int)(slippage * PipValue(OrderSymbol())), arrowcolor);

            if (success == true)
            {
                if (USE_VIRTUAL_STOPS) {
                    VirtualStopsDriver("clear", ticket);
                }

                expirationWorker.RemoveExpiration(ticket);

                OnTrade();

                return true;
            }

            //-- errors -------------------------------------------------------
            int erraction = CheckForTradingError(GetLastError(), "Closing trade #" + (string)ticket + " error");

            switch(erraction)
            {
                case 0: break;    // no error
                case 1: continue; // overcomable error
                case 2: break;    // fatal error
            }

            break;
        }

        return false;
    }

    template<typename DT1, typename DT2>
    bool CompareValues(string sign, DT1 v1, DT2 v2)
    {
            if (sign == ">") return(v1 > v2);
        else if (sign == "<") return(v1 < v2);
        else if (sign == ">=") return(v1 >= v2);
        else if (sign == "<=") return(v1 <= v2);
        else if (sign == "==") return(v1 == v2);
        else if (sign == "!=") return(v1 != v2);
        else if (sign == "x>") return(v1 > v2);
        else if (sign == "x<") return(v1 < v2);

        return false;
    }

    string CurrentSymbol(string symbol = "")
    {
    static string memory = "";

        // Set
    if (symbol != "")
        {
            memory = symbol;
        }
        // Get
        else if (memory == "")
        {
            memory = Symbol();
        }

    return memory;
    }

    ENUM_TIMEFRAMES CurrentTimeframe(ENUM_TIMEFRAMES timeframe = -1)
    {
        static ENUM_TIMEFRAMES memory = 0;

    if (timeframe >= 0) {memory = timeframe;}

    return memory;
    }

    double CustomPoint(string symbol)
    {
        static string symbols[];
        static double points[];
        static string last_symbol = "-";
        static double last_point  = 0;
        static int last_i         = 0;
        static int size           = 0;

        //-- variant A) use the cache for the last used symbol
        if (symbol == last_symbol)
        {
            return last_point;
        }

        //-- variant B) search in the array cache
        int i			= last_i;
        int start_i	= i;
        bool found	= false;

        if (size > 0)
        {
            while (true)
            {
                if (symbols[i] == symbol)
                {
                    last_symbol	= symbol;
                    last_point	= points[i];
                    last_i		= i;

                    return last_point;
                }

                i++;

                if (i >= size)
                {
                    i = 0;
                }
                if (i == start_i) {break;}
            }
        }

        //-- variant C) add this symbol to the cache
        i		= size;
        size	= size + 1;

        ArrayResize(symbols, size);
        ArrayResize(points, size);

        symbols[i]	= symbol;
        points[i]	= 0;
        last_symbol	= symbol;
        last_i		= i;

        //-- unserialize rules from FXD_POINT_FORMAT_RULES
        string rules[];
        StringExplode(",", POINT_FORMAT_RULES, rules);

        int rules_count = ArraySize(rules);

        if (rules_count > 0)
        {
            string rule[];

            for (int r = 0; r < rules_count; r++)
            {
                StringExplode("=", rules[r], rule);

                //-- a single rule must contain 2 parts, [0] from and [1] to
                if (ArraySize(rule) != 2) {continue;}

                double from = StringToDouble(rule[0]);
                double to	= StringToDouble(rule[1]);

                //-- "to" must be a positive number, different than 0
                if (to <= 0) {continue;}

                //-- "from" can be a number or a string
                // a) string
                if (from == 0 && StringLen(rule[0]) > 0)
                {
                    string s_from = rule[0];
                    int pos       = StringFind(s_from, "?");

                    if (pos < 0) // ? not found
                    {
                        if (StringFind(symbol, s_from) == 0) {points[i] = to;}
                    }
                    else if (pos == 0) // ? is the first symbol => match the second symbol
                    {
                        if (StringFind(symbol, StringSubstr(s_from, 1), 3) == 3)
                        {
                            points[i] = to;
                        }
                    }
                    else if (pos > 0) // ? is the second symbol => match the first symbol
                    {
                        if (StringFind(symbol, StringSubstr(s_from, 0, pos)) == 0)
                        {
                            points[i] = to;
                        }
                    }
                }

                // b) number
                if (from == 0) {continue;}

                if (SymbolInfoDouble(symbol, SYMBOL_POINT) == from)
                {
                    points[i] = to;
                }
            }
        }

        if (points[i] == 0)
        {
            points[i] = SymbolInfoDouble(symbol, SYMBOL_POINT);
        }

        last_point = points[i];

        return last_point;
    }

    bool DeleteOrder(ulong ticket, color arrowcolor=clrNONE)
    {
    bool success=false;
    if (!OrderSelect((int)ticket,SELECT_BY_TICKET,MODE_TRADES)) {return(false);}
    
    while(true)
    {
        //-- wait if needed -----------------------------------------------
        WaitTradeContextIfBusy();
        //-- delete -------------------------------------------------------
        success=OrderDelete((int)ticket,arrowcolor);
        if (success==true) {
            if (USE_VIRTUAL_STOPS) {
                VirtualStopsDriver("clear",ticket);
            }
            OnTrade();
            return(true);
        }
        //-- error check --------------------------------------------------
        int erraction=CheckForTradingError(GetLastError(), "Deleting order #"+(string)ticket+" error");
        switch(erraction)
        {
            case 0: break;    // no error
            case 1: continue; // overcomable error
            case 2: break;    // fatal error
        }
        break;
    }
    return(false);
    }

    void DrawSpreadInfo()
    {
    static bool allow_draw = true;
    if (allow_draw==false) {return;}
    if (MQLInfoInteger(MQL_TESTER) && !MQLInfoInteger(MQL_VISUAL_MODE)) {allow_draw=false;} // Allowed to draw only once in testing mode

    static bool passed         = false;
    static double max_spread   = 0;
    static double min_spread   = EMPTY_VALUE;
    static double avg_spread   = 0;
    static double avg_add      = 0;
    static double avg_cnt      = 0;

    double custom_point = CustomPoint(Symbol());
    double current_spread = 0;
    if (custom_point > 0) {
        current_spread = (SymbolInfoDouble(Symbol(),SYMBOL_ASK)-SymbolInfoDouble(Symbol(),SYMBOL_BID))/custom_point;
    }
    if (current_spread > max_spread) {max_spread = current_spread;}
    if (current_spread < min_spread) {min_spread = current_spread;}
    
    avg_cnt++;
    avg_add     = avg_add + current_spread;
    avg_spread  = avg_add / avg_cnt;

    int x=0; int y=0;
    string name;

    // create objects
    if (passed == false)
    {
        passed=true;
        
        name="fxd_spread_current_label";
        if (ObjectFind(0, name)==-1) {
            ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
            ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x+1);
            ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y+1);
            ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_LOWER);
            ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
            ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
            ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 18);
            ObjectSetInteger(0, name, OBJPROP_COLOR, clrDarkOrange);
            ObjectSetString(0, name, OBJPROP_FONT, "Arial");
            ObjectSetString(0, name, OBJPROP_TEXT, "Spread:");
        }
        name="fxd_spread_max_label";
        if (ObjectFind(0, name)==-1) {
            ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
            ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x+148);
            ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y+17);
            ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_LOWER);
            ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
            ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
            ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 7);
            ObjectSetInteger(0, name, OBJPROP_COLOR, clrOrangeRed);
            ObjectSetString(0, name, OBJPROP_FONT, "Arial");
            ObjectSetString(0, name, OBJPROP_TEXT, "max:");
        }
        name="fxd_spread_avg_label";
        if (ObjectFind(0, name)==-1) {
            ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
            ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x+148);
            ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y+9);
            ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_LOWER);
            ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
            ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
            ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 7);
            ObjectSetInteger(0, name, OBJPROP_COLOR, clrDarkOrange);
            ObjectSetString(0, name, OBJPROP_FONT, "Arial");
            ObjectSetString(0, name, OBJPROP_TEXT, "avg:");
        }
        name="fxd_spread_min_label";
        if (ObjectFind(0, name)==-1) {
            ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
            ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x+148);
            ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y+1);
            ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_LOWER);
            ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
            ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
            ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 7);
            ObjectSetInteger(0, name, OBJPROP_COLOR, clrGold);
            ObjectSetString(0, name, OBJPROP_FONT, "Arial");
            ObjectSetString(0, name, OBJPROP_TEXT, "min:");
        }
        name="fxd_spread_current";
        if (ObjectFind(0, name)==-1) {
            ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
            ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x+93);
            ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y+1);
            ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_LOWER);
            ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
            ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
            ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 18);
            ObjectSetInteger(0, name, OBJPROP_COLOR, clrDarkOrange);
            ObjectSetString(0, name, OBJPROP_FONT, "Arial");
            ObjectSetString(0, name, OBJPROP_TEXT, "0");
        }
        name="fxd_spread_max";
        if (ObjectFind(0, name)==-1) {
            ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
            ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x+173);
            ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y+17);
            ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_LOWER);
            ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
            ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
            ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 7);
            ObjectSetInteger(0, name, OBJPROP_COLOR, clrOrangeRed);
            ObjectSetString(0, name, OBJPROP_FONT, "Arial");
            ObjectSetString(0, name, OBJPROP_TEXT, "0");
        }
        name="fxd_spread_avg";
        if (ObjectFind(0, name)==-1) {
            ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
            ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x+173);
            ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y+9);
            ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_LOWER);
            ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
            ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
            ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 7);
            ObjectSetInteger(0, name, OBJPROP_COLOR, clrDarkOrange);
            ObjectSetString(0, name, OBJPROP_FONT, "Arial");
            ObjectSetString(0, name, OBJPROP_TEXT, "0");
        }
        name="fxd_spread_min";
        if (ObjectFind(0, name)==-1) {
            ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
            ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x+173);
            ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y+1);
            ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_LOWER);
            ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
            ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
            ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 7);
            ObjectSetInteger(0, name, OBJPROP_COLOR, clrGold);
            ObjectSetString(0, name, OBJPROP_FONT, "Arial");
            ObjectSetString(0, name, OBJPROP_TEXT, "0");
        }
    }
    
    ObjectSetString(0, "fxd_spread_current", OBJPROP_TEXT, DoubleToStr(current_spread,2));
    ObjectSetString(0, "fxd_spread_max", OBJPROP_TEXT, DoubleToStr(max_spread,2));
    ObjectSetString(0, "fxd_spread_avg", OBJPROP_TEXT, DoubleToStr(avg_spread,2));
    ObjectSetString(0, "fxd_spread_min", OBJPROP_TEXT, DoubleToStr(min_spread,2));
    }

    string DrawStatus(string text="")
    {
    static string memory;
    if (text=="") {
        return(memory);
    }
    
    static bool passed = false;
    int x=210; int y=0;
    string name;

    //-- draw the objects once
    if (passed == false)
    {
        passed = true;
        name="fxd_status_title";
        ObjectCreate(0,name, OBJ_LABEL, 0, 0, 0);
        ObjectSetInteger(0,name, OBJPROP_BACK, false);
        ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_LOWER);
        ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
        ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0,name, OBJPROP_XDISTANCE, x);
        ObjectSetInteger(0,name, OBJPROP_YDISTANCE, y+17);
        ObjectSetString(0,name, OBJPROP_TEXT, "Status");
        ObjectSetString(0,name, OBJPROP_FONT, "Arial");
        ObjectSetInteger(0,name, OBJPROP_FONTSIZE, 7);
        ObjectSetInteger(0,name, OBJPROP_COLOR, clrGray);
        
        name="fxd_status_text";
        ObjectCreate(0,name, OBJ_LABEL, 0, 0, 0);
        ObjectSetInteger(0,name, OBJPROP_BACK, false);
        ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_LOWER);
        ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
        ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0,name, OBJPROP_XDISTANCE, x+2);
        ObjectSetInteger(0,name, OBJPROP_YDISTANCE, y+1);
        ObjectSetString(0,name, OBJPROP_FONT, "Arial");
        ObjectSetInteger(0,name, OBJPROP_FONTSIZE, 12);
        ObjectSetInteger(0,name, OBJPROP_COLOR, clrAqua);
    }

    //-- update the text when needed
    if (text != memory) {
        memory=text;
        ObjectSetString(0,"fxd_status_text", OBJPROP_TEXT, text);
    }
    
    return(text);
    }

    double DynamicLots(string symbol, string mode="balance", double value=0, double sl=0, string align="align", double RJFR_initial_lots=0)
    {
    double size=0;
    double LotStep=MarketInfo(symbol,MODE_LOTSTEP);
    double LotSize=MarketInfo(symbol,MODE_LOTSIZE);
    double MinLots=MarketInfo(symbol,MODE_MINLOT);
    double MaxLots=MarketInfo(symbol,MODE_MAXLOT);
    double TickValue=MarketInfo(symbol,MODE_TICKVALUE);
    double point=MarketInfo(symbol,MODE_POINT);
    double ticksize=MarketInfo(symbol,MODE_TICKSIZE);
    double margin_required=MarketInfo(symbol,MODE_MARGINREQUIRED);
    
    if (mode=="fixed" || mode=="lots")     {size=value;}
    else if (mode=="block-equity")      {size=(value/100)*AccountEquity()/margin_required;}
    else if (mode=="block-balance")     {size=(value/100)*AccountBalance()/margin_required;}
    else if (mode=="block-freemargin")  {size=(value/100)*AccountFreeMargin()/margin_required;}
    else if (mode=="equity")      {size=(value/100)*AccountEquity()/(LotSize*TickValue);}
    else if (mode=="balance")     {size=(value/100)*AccountBalance()/(LotSize*TickValue);}
    else if (mode=="freemargin")  {size=(value/100)*AccountFreeMargin()/(LotSize*TickValue);}
    else if (mode=="equityRisk")     {size=((value/100)*AccountEquity())/(sl*((TickValue/ticksize)*point)*PipValue(symbol));}
    else if (mode=="balanceRisk")    {size=((value/100)*AccountBalance())/(sl*((TickValue/ticksize)*point)*PipValue(symbol));}
    else if (mode=="freemarginRisk") {size=((value/100)*AccountFreeMargin())/(sl*((TickValue/ticksize)*point)*PipValue(symbol));}
    else if (mode=="fixedRisk")   {size=(value)/(sl*((TickValue/ticksize)*point)*PipValue(symbol));}
    else if (mode=="fixedRatio" || mode=="RJFR") {
        
        /////
        // Ryan Jones Fixed Ratio MM static data
        static double RJFR_start_lots=0;
        static double RJFR_delta=0;
        static double RJFR_units=1;
        static double RJFR_target_lower=0;
        static double RJFR_target_upper=0;
        /////
        
        if (RJFR_start_lots<=0) {RJFR_start_lots=value;}
        if (RJFR_start_lots<MinLots) {RJFR_start_lots=MinLots;}
        if (RJFR_delta<=0) {RJFR_delta=sl;}
        if (RJFR_target_upper<=0) {
            RJFR_target_upper=AccountEquity()+(RJFR_units*RJFR_delta);
            Print("Fixed Ratio MM: Units=>",RJFR_units,"; Delta=",RJFR_delta,"; Upper Target Equity=>",RJFR_target_upper);
        }
        if (AccountEquity()>=RJFR_target_upper)
        {
            while(true) {
                Print("Fixed Ratio MM going up to ",(RJFR_start_lots*(RJFR_units+1))," lots: Equity is above Upper Target Equity (",AccountEquity(),">=",RJFR_target_upper,")");
                RJFR_units++;
                RJFR_target_lower=RJFR_target_upper;
                RJFR_target_upper=RJFR_target_upper+(RJFR_units*RJFR_delta);
                Print("Fixed Ratio MM: Units=>",RJFR_units,"; Delta=",RJFR_delta,"; Lower Target Equity=>",RJFR_target_lower,"; Upper Target Equity=>",RJFR_target_upper);
                if (AccountEquity()<RJFR_target_upper) {break;}
            }
        }
        else if (AccountEquity()<=RJFR_target_lower)
        {
            while(true) {
            if (AccountEquity()>RJFR_target_lower) {break;}
                if (RJFR_units>1) {         
                Print("Fixed Ratio MM going down to ",(RJFR_start_lots*(RJFR_units-1))," lots: Equity is below Lower Target Equity | ", AccountEquity()," <= ",RJFR_target_lower,")");
                RJFR_target_upper=RJFR_target_lower;
                RJFR_target_lower=RJFR_target_lower-((RJFR_units-1)*RJFR_delta);
                RJFR_units--;
                Print("Fixed Ratio MM: Units=>",RJFR_units,"; Delta=",RJFR_delta,"; Lower Target Equity=>",RJFR_target_lower,"; Upper Target Equity=>",RJFR_target_upper);
                } else {break;}
            }
        }
        size=RJFR_start_lots*RJFR_units;
    }
    
        if (size==EMPTY_VALUE) {size=0;}
        
    size=MathRound(size/LotStep)*LotStep;
    
    static bool alert_min_lots=false;
    if (size<MinLots && alert_min_lots==false) {
        alert_min_lots=true;
        Alert("You want to trade ",size," lot, but your broker's minimum is ",MinLots," lot. The trade/order will continue with ",MinLots," lot instead of ",size," lot. The same rule will be applied for next trades/orders with desired lot size lower than the minimum. You will not see this message again until you restart the program.");
    }
    
    if (align=="align") {
        if (size<MinLots) {size=MinLots;}
        if (size>MaxLots) {size=MaxLots;}
    }
    
    return (size);
    }

    string ErrorMessage(int error_code=-1)
    {
        string e = "";
        
        if (error_code < 0) {error_code = GetLastError();}
        
        switch(error_code)
        {
            //-- codes returned from trade server
            case 0:	return("");
            case 1:	e = "No error returned"; break;
            case 2:	e = "Common error"; break;
            case 3:	e = "Invalid trade parameters"; break;
            case 4:	e = "Trade server is busy"; break;
            case 5:	e = "Old version of the client terminal"; break;
            case 6:	e = "No connection with trade server"; break;
            case 7:	e = "Not enough rights"; break;
            case 8:	e = "Too frequent requests"; break;
            case 9:	e = "Malfunctional trade operation (never returned error)"; break;
            case 64:  e = "Account disabled"; break;
            case 65:  e = "Invalid account"; break;
            case 128: e = "Trade timeout"; break;
            case 129: e = "Invalid price"; break;
            case 130: e = "Invalid Sl or TP"; break;
            case 131: e = "Invalid trade volume"; break;
            case 132: e = "Market is closed"; break;
            case 133: e = "Trade is disabled"; break;
            case 134: e = "Not enough money"; break;
            case 135: e = "Price changed"; break;
            case 136: e = "Off quotes"; break;
            case 137: e = "Broker is busy (never returned error)"; break;
            case 138: e = "Requote"; break;
            case 139: e = "Order is locked"; break;
            case 140: e = "Only long trades allowed"; break;
            case 141: e = "Too many requests"; break;
            case 145: e = "Modification denied because order too close to market"; break;
            case 146: e = "Trade context is busy"; break;
            case 147: e = "Expirations are denied by broker"; break;
            case 148: e = "Amount of open and pending orders has reached the limit"; break;
            case 149: e = "Hedging is prohibited"; break;
            case 150: e = "Prohibited by FIFO rules"; break;
            
            //-- mql4 errors
            case 4000: e = "No error"; break;
            case 4001: e = "Wrong function pointer"; break;
            case 4002: e = "Array index is out of range"; break;
            case 4003: e = "No memory for function call stack"; break;
            case 4004: e = "Recursive stack overflow"; break;
            case 4005: e = "Not enough stack for parameter"; break;
            case 4006: e = "No memory for parameter string"; break;
            case 4007: e = "No memory for temp string"; break;
            case 4008: e = "Not initialized string"; break;
            case 4009: e = "Not initialized string in array"; break;
            case 4010: e = "No memory for array string"; break;
            case 4011: e = "Too long string"; break;
            case 4012: e = "Remainder from zero divide"; break;
            case 4013: e = "Zero divide"; break;
            case 4014: e = "Unknown command"; break;
            case 4015: e = "Wrong jump"; break;
            case 4016: e = "Not initialized array"; break;
            case 4017: e = "dll calls are not allowed"; break;
            case 4018: e = "Cannot load library"; break;
            case 4019: e = "Cannot call function"; break;
            case 4020: e = "Expert function calls are not allowed"; break;
            case 4021: e = "Not enough memory for temp string returned from function"; break;
            case 4022: e = "System is busy"; break;
            case 4050: e = "Invalid function parameters count"; break;
            case 4051: e = "Invalid function parameter value"; break;
            case 4052: e = "String function internal error"; break;
            case 4053: e = "Some array error"; break;
            case 4054: e = "Incorrect series array using"; break;
            case 4055: e = "Custom indicator error"; break;
            case 4056: e = "Arrays are incompatible"; break;
            case 4057: e = "Global variables processing error"; break;
            case 4058: e = "Global variable not found"; break;
            case 4059: e = "Function is not allowed in testing mode"; break;
            case 4060: e = "Function is not confirmed"; break;
            case 4061: e = "Send mail error"; break;
            case 4062: e = "String parameter expected"; break;
            case 4063: e = "Integer parameter expected"; break;
            case 4064: e = "Double parameter expected"; break;
            case 4065: e = "Array as parameter expected"; break;
            case 4066: e = "Requested history data in update state"; break;
            case 4099: e = "End of file"; break;
            case 4100: e = "Some file error"; break;
            case 4101: e = "Wrong file name"; break;
            case 4102: e = "Too many opened files"; break;
            case 4103: e = "Cannot open file"; break;
            case 4104: e = "Incompatible access to a file"; break;
            case 4105: e = "No order selected"; break;
            case 4106: e = "Unknown symbol"; break;
            case 4107: e = "Invalid price parameter for trade function"; break;
            case 4108: e = "Invalid ticket"; break;
            case 4109: e = "Trade is not allowed in the expert properties"; break;
            case 4110: e = "Longs are not allowed in the expert properties"; break;
            case 4111: e = "Shorts are not allowed in the expert properties"; break;
            
            //-- objects errors
            case 4200: e = "Object is already exist"; break;
            case 4201: e = "Unknown object property"; break;
            case 4202: e = "Object is not exist"; break;
            case 4203: e = "Unknown object type"; break;
            case 4204: e = "No object name"; break;
            case 4205: e = "Object coordinates error"; break;
            case 4206: e = "No specified subwindow"; break;
            case 4207: e = "Graphical object error"; break;  
            case 4210: e = "Unknown chart property"; break;
            case 4211: e = "Chart not found"; break;
            case 4212: e = "Chart subwindow not found"; break;
            case 4213: e = "Chart indicator not found"; break;
            case 4220: e = "Symbol select error"; break;
            case 4250: e = "Notification error"; break;
            case 4251: e = "Notification parameter error"; break;
            case 4252: e = "Notifications disabled"; break;
            case 4253: e = "Notification send too frequent"; break;
            
            //-- ftp errors
            case 4260: e = "FTP server is not specified"; break;
            case 4261: e = "FTP login is not specified"; break;
            case 4262: e = "FTP connection failed"; break;
            case 4263: e = "FTP connection closed"; break;
            case 4264: e = "FTP path not found on server"; break;
            case 4265: e = "File not found in the MQL4\\Files directory to send on FTP server"; break;
            case 4266: e = "Common error during FTP data transmission"; break;
            
            //-- filesystem errors
            case 5001: e = "Too many opened files"; break;
            case 5002: e = "Wrong file name"; break;
            case 5003: e = "Too long file name"; break;
            case 5004: e = "Cannot open file"; break;
            case 5005: e = "Text file buffer allocation error"; break;
            case 5006: e = "Cannot delete file"; break;
            case 5007: e = "Invalid file handle (file closed or was not opened)"; break;
            case 5008: e = "Wrong file handle (handle index is out of handle table)"; break;
            case 5009: e = "File must be opened with FILE_WRITE flag"; break;
            case 5010: e = "File must be opened with FILE_READ flag"; break;
            case 5011: e = "File must be opened with FILE_BIN flag"; break;
            case 5012: e = "File must be opened with FILE_TXT flag"; break;
            case 5013: e = "File must be opened with FILE_TXT or FILE_CSV flag"; break;
            case 5014: e = "File must be opened with FILE_CSV flag"; break;
            case 5015: e = "File read error"; break;
            case 5016: e = "File write error"; break;
            case 5017: e = "String size must be specified for binary file"; break;
            case 5018: e = "Incompatible file (for string arrays-TXT, for others-BIN)"; break;
            case 5019: e = "File is directory, not file"; break;
            case 5020: e = "File does not exist"; break;
            case 5021: e = "File cannot be rewritten"; break;
            case 5022: e = "Wrong directory name"; break;
            case 5023: e = "Directory does not exist"; break;
            case 5024: e = "Specified file is not directory"; break;
            case 5025: e = "Cannot delete directory"; break;
            case 5026: e = "Cannot clean directory"; break;
            
            //-- other errors
            case 5027: e = "Array resize error"; break;
            case 5028: e = "String resize error"; break;
            case 5029: e = "Structure contains strings or dynamic arrays"; break;
            
            //-- http request
            case 5200: e = "Invalid URL"; break;
            case 5201: e = "Failed to connect to specified URL"; break;
            case 5202: e = "Timeout exceeded"; break;
            case 5203: e = "HTTP request failed"; break;

            default:	e = "Unknown error";
        }

        e = StringConcatenate(e, " (", error_code, ")");
        
        return e;
    }

    datetime ExpirationTime(string mode="GTC",int days=0, int hours=0, int minutes=0, datetime custom=0)
    {
        datetime now        = TimeCurrent();
    datetime expiration = now;

            if (mode == "GTC" || mode == "") {expiration = 0;}
        else if (mode == "today")             {expiration = (datetime)(MathFloor((now + 86400.0) / 86400.0) * 86400.0);}
        else if (mode == "specified")
        {
            expiration = 0;

            if ((days + hours + minutes) > 0)
            {
                expiration = now + (86400 * days) + (3600 * hours) + (60 * minutes);
            }
        }
        else
        {
            if (custom <= now)
            {
                if (custom < 31557600)
                {
                    custom = now + custom;
                }
                else
                {
                    custom = 0;
                }
            }

            expiration = custom;
        }

        return expiration;
    }

    class ExpirationWorker
    {
    private:
        struct CachedItems
        {
            int orderType;
            long ticket;
            datetime expiration;
        };

        CachedItems cachedItems[];
        long chartID;
        string chartObjectPrefix;
        string chartObjectSuffix;

        template<typename T>
        void ArrayClone(T &dest[], T &src[])
        {
            int size = ArraySize(src);
            ArrayResize(dest, size);

            for (int i = 0; i < size; i++)
            {
                dest[i] = src[i];
            }
        }

        void InitialDiscovery()
        {
            ArrayResize(cachedItems, 0);

            int total = OrdersTotal();

            for (int index = 0; index <= total; index++)
            {
                long ticket = GetTicketByIndex(index);

                if (ticket == 0) continue;

                datetime expiration = GetExpirationFromObject(ticket);

                if (expiration > 0)
                {
                    if (OrderSelect((int)ticket, SELECT_BY_TICKET, MODE_TRADES)) {
                        SetExpirationInCache(OrderType(), ticket, expiration);
                    }
                }
            }
        }

        long GetTicketByIndex(int index)
        {
            long ticket = 0;

            if (OrderSelect(index, SELECT_BY_POS, MODE_TRADES))
            {
                if (OrderType() <= OP_SELL) ticket = (long)OrderTicket();
            }

            return ticket;
        }

        datetime GetExpirationFromObject(long ticket)
        {
            datetime expiration = (datetime)0;
            
            string objectName = chartObjectPrefix + IntegerToString(ticket) + chartObjectSuffix;

            if (ObjectFind(chartID, objectName) == chartID)
            {
                expiration = (datetime)ObjectGetInteger(chartID, objectName, OBJPROP_TIME);
            }

            return expiration;
        }

        bool RemoveExpirationObject(long ticket)
        {
            bool success      = false;
            string objectName = "";

            objectName = chartObjectPrefix + IntegerToString(ticket) + chartObjectSuffix;
            success    = ObjectDelete(chartID, objectName);

            return success;
        }

        void RemoveExpirationFromCache(long ticket)
        {
            int size = ArraySize(cachedItems);
            CachedItems newItems[];
            int newSize = 0;
            bool itemRemoved = false;

            for (int i = 0; i < size; i++)
            {
                if (cachedItems[i].ticket == ticket)
                {
                    itemRemoved = true;
                }
                else
                {
                    newSize++;
                    ArrayResize(newItems, newSize);
                    newItems[newSize - 1].orderType  = cachedItems[i].orderType;
                    newItems[newSize - 1].ticket     = cachedItems[i].ticket;
                    newItems[newSize - 1].expiration = cachedItems[i].expiration;
                }
            }

            if (itemRemoved) ArrayClone(cachedItems, newItems);
        }

        void SetExpirationInCache(int orderType, long ticket, datetime expiration)
        {
            bool alreadyExists = false;
            int size           = ArraySize(cachedItems);

            for (int i = 0; i < size; i++)
            {
                if (cachedItems[i].ticket == ticket)
                {
                    cachedItems[i].orderType  = orderType;
                    cachedItems[i].expiration = expiration;
                    alreadyExists = true;
                    break;
                }
            }

            if (alreadyExists == false)
            {
                ArrayResize(cachedItems, size + 1);
                cachedItems[size].orderType  = orderType;
                cachedItems[size].ticket     = ticket;
                cachedItems[size].expiration = expiration;
            }
        }

        bool SetExpirationInObject(int orderType, long ticket, datetime expiration)
        {
            if (!OrderSelect((int)ticket, SELECT_BY_TICKET)) return false;

            string objectName = chartObjectPrefix + IntegerToString(ticket) + chartObjectSuffix;
            double price      = OrderOpenPrice();

            if (ObjectFind(chartID, objectName) == chartID)
            {
                ObjectSetInteger(chartID, objectName, OBJPROP_TIME, expiration);
                ObjectSetDouble(chartID, objectName, OBJPROP_PRICE, price);
            }
            else
            {
                ObjectCreate(chartID, objectName, OBJ_ARROW, 0, expiration, price);
            }

            ObjectSetInteger(chartID, objectName, OBJPROP_ARROWCODE, 77);
            ObjectSetInteger(chartID, objectName, OBJPROP_HIDDEN, true);
            ObjectSetInteger(chartID, objectName, OBJPROP_ANCHOR, ANCHOR_TOP);
            ObjectSetInteger(chartID, objectName, OBJPROP_COLOR, clrRed);
            ObjectSetInteger(chartID, objectName, OBJPROP_SELECTABLE, false);
            ObjectSetInteger(chartID, objectName, OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS);
            ObjectSetString(chartID, objectName, OBJPROP_TEXT, TimeToString(expiration));

            return true;
        }
        
        bool TradeExists(long ticket)
        {
            bool exists  = false;

            for (int i = 0; i < OrdersTotal(); i++)
            {
                if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;

                if (OrderType() > OP_SELL) continue;

                if (OrderTicket() == ticket)
                {
                    exists = true;
                    break;
                }
            }

            return exists;
        }

        bool PendingOrderExists(long ticket)
        {
            bool exists  = false;

            for (int i = 0; i < OrdersTotal(); i++)
            {
                if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
                
                if (OrderType() <= OP_SELL || OrderType() > OP_SELLSTOP) continue; 

                if (OrderTicket() == ticket)
                {
                    exists = true;
                    break;
                }
            }

            return exists;
        }

    public:
        // Default constructor
        ExpirationWorker()
        {
            chartID           = 0;
            chartObjectPrefix = "#";
            chartObjectSuffix = " Expiration Marker";

            InitialDiscovery();
        }

        void SetExpiration(long ticket, datetime expiration)
        {
            if (expiration <= 0)
            {
                RemoveExpiration(ticket);
            }
            else
            {
                int orderType = OrderType();

                SetExpirationInObject(orderType, ticket, expiration);
                SetExpirationInCache(orderType, ticket, expiration);
            }
        }

        datetime GetExpiration(long ticket)
        {
            datetime expiration = (datetime)0;
            int size            = ArraySize(cachedItems);

            for (int i = 0; i < size; i++)
            {
                if (cachedItems[i].ticket == ticket)
                {
                    expiration = cachedItems[i].expiration;
                    break;
                }
            }

            return expiration;
        }

        void RemoveExpiration(long ticket)
        {
            RemoveExpirationObject(ticket);
            RemoveExpirationFromCache(ticket);
        }

        void Run()
        {
            int count = ArraySize(cachedItems);

            if (count > 0)
            {
                datetime timeNow = TimeCurrent();

                for (int i = 0; i < count; i++)
                {
                    if (timeNow >= cachedItems[i].expiration)
                    {
                        int orderType         = cachedItems[i].orderType;
                        long ticket           = cachedItems[i].ticket;
                        bool removeExpiration = false;

                        if (orderType < 2 && TradeExists(ticket))
                        {
                            if (CloseTrade(ticket))
                            {
                                Print("close #", ticket, " by expiration");
                                removeExpiration = true;
                            }
                        }
                        else if (orderType >= 2 && PendingOrderExists(ticket))
                        {
                            if (DeleteOrder(ticket))
                            {
                                Print("delete #", ticket, " by expiration");
                                removeExpiration = true;
                            }
                        }
                        else
                        {
                            removeExpiration = true;
                        }

                        if (removeExpiration)
                        {
                            RemoveExpiration(ticket);

                            // Removing expiration causes change in the size of the cache,
                            // so reset of the size and one step back of the index is needed
                            count = ArraySize(cachedItems);
                            i--;
                        }
                    }
                }
            }
        }
    };

    ExpirationWorker expirationWorker;

    bool FilterOrderBy(
        string group_mode    = "all",
        string group         = "0",
        string market_mode   = "all",
        string market        = "",
        string BuysOrSells   = "both",
        string LimitsOrStops = "both",
        int TradesOrders     = 0,
        bool onTrade         = false
    ) {
        // TradesOrders = 0 - trades only
        // TradesOrders = 1 - orders only
        // TradesOrders = 2 - trades and orders - INCOMPLETE, DO NOT USE!

        //-- db
        static string markets[];
        static string market0   = "-";
        static int markets_size = 0;
        
        static string groups[];
        static string group0   = "-";
        static int groups_size = 0;
        
        //-- local variables
        bool type_pass   = false;
        bool market_pass = false;
        bool group_pass  = false;
        
        int i, type, magic_number;
        string symbol;

        // Trades
        if (onTrade == false)
        {
            type         = OrderType();
            magic_number = OrderMagicNumber();
            symbol       = OrderSymbol();
        }
        else
        {
            type         = e_attrType();
            magic_number = e_attrMagicNumber();
            symbol       = e_attrSymbol();
        }

        if (TradesOrders == 0)
        {
            if (
                    (BuysOrSells == "both"  && (type == OP_BUY || type == OP_SELL))
                || (BuysOrSells == "buys"  && type == OP_BUY)
                || (BuysOrSells == "sells" && type == OP_SELL)
                
                )
            {
                type_pass = true;
            }
        }
        // Pending orders
        else if (TradesOrders == 1)
        {
            if (
                    (BuysOrSells == "both" && (type == OP_BUYLIMIT || type == OP_BUYSTOP || type == OP_SELLLIMIT || type == OP_SELLSTOP))
                ||	(BuysOrSells == "buys" && (type == OP_BUYLIMIT || type == OP_BUYSTOP))
                || (BuysOrSells == "sells" && (type == OP_SELLLIMIT || type == OP_SELLSTOP))
                )
            {
                if (
                        (LimitsOrStops == "both" && (type == OP_BUYSTOP || type == OP_SELLSTOP || type == OP_BUYLIMIT || type == OP_SELLLIMIT))
                    ||	(LimitsOrStops == "stops" && (type == OP_BUYSTOP || type == OP_SELLSTOP))
                    || (LimitsOrStops == "limits" && (type == OP_BUYLIMIT || type == OP_SELLLIMIT))					
                    )
                {
                    type_pass = true;
                }
            }
        }
        //-- Trades and orders --------------------------------------------
        else
        {
            if (
                    (BuysOrSells == "both")
                || (BuysOrSells == "buys"  && (type == OP_BUY || type == OP_BUYLIMIT || type == OP_BUYSTOP))
                || (BuysOrSells == "sells" && (type == OP_SELL || type == OP_SELLLIMIT || type == OP_SELLSTOP))
                )
            {
                type_pass = true;
            }
        }

        if (type_pass == false)
        {
            return false;
        }

        //-- check group
        if (group_mode == "group")
        {
            if (group == "")
            {
                if (magic_number == MagicStart)
            {
                group_pass = true;
            }
        }
        else
        {
                if (group0 != group)
                {
                    group0 = group;
                    StringExplode(",", group,groups);
                    groups_size = ArraySize(groups);

                    for(i = 0; i < groups_size; i++)
                    {
                        groups[i] = StringTrimRight(groups[i]);
                        groups[i] = StringTrimLeft(groups[i]);

                        if (groups[i] == "") {groups[i] = "0";}
                    }
                }
            
                for(i = 0; i < groups_size; i++)
                {
                    if (magic_number == (MagicStart+(int)groups[i]))
                    {
                        group_pass = true;

                        break;
                    }
                }
            }
        }
        else if (group_mode == "all" || (group_mode == "manual" && magic_number == 0))
        {
            group_pass = true;  
        }

        if (group_pass == false)
        {
            return false;
        }

        // check market
        if (market_mode == "all")
        {
            market_pass = true;
        }
        else
        {
            if (symbol == market)
        {
            market_pass = true;
        }
        else
        {
                if (market0 != market)
                {
                    market0 = market;

                    if (market == "")
                    {
                        markets_size = 1;
                        ArrayResize(markets, 1);
                        markets[0] = Symbol();
                    }
                    else
                    {
                        StringExplode(",", market, markets);
                        markets_size = ArraySize(markets);

                        for(i = 0; i < markets_size; i++)
                        {
                            markets[i] = StringTrimRight(markets[i]);
                            markets[i] = StringTrimLeft(markets[i]);

                            if (markets[i] == "") {markets[i] = Symbol();}
                        }
                    }
                }

                for(i = 0; i < markets_size; i++)
                {
                    if (symbol == markets[i])
                    {
                        market_pass = true;

                        break;
                    }
                }
            }
        }

        if (market_pass == false)
        {
            return false;
        }

        return true;
    }

    /**
    * This overload works for numeric values and for boolean values
    */
    template<typename T>
    string FormatValueForPrinting(
        T value,
        int digits,
        int timeFormat
    ) {
        string outputValue = "";
        string typeName    = typename(value);

        if (typeName == "double" || typeName == "float")
        {
            if (digits >= -16 && digits <= 8)
            {
                if (value > -1.0 && value < 1.0)
                {
                    /**
                    * Find how many zeroes are after the point, but before the first non-zero digit.
                    * For example 0.000195 has 3 zeroes
                    * The function would return negative value for values bigger than 0
                    *
                    * @see https://stackoverflow.com/questions/31001901/how-can-i-count-the-number-of-zero-decimals-in-javascript/31002148#31002148
                    */
                    int zeroesAfterPoint = (int)-MathFloor(MathLog10(MathAbs(value)) + 1);

                    digits = zeroesAfterPoint + digits;
                }
                
                T normalizedValue  = NormalizeDouble(value, digits);
                outputValue = DoubleToString(normalizedValue, digits);
            }
            else
            {
                outputValue = (string)NormalizeDouble(value, 8);
            }
        }
        else {
            outputValue = IntegerToString((long)value);
        }

        return outputValue;
    }

    /**
    * Bool overload
    */
    string FormatValueForPrinting(
        bool value,
        int digits,
        int timeFormat
    ) {
        return (value) ? "true" : "false";
    }

    /**
    * Datetime overload
    */
    string FormatValueForPrinting(
        datetime value,
        int digits,
        int timeFormat
    ) {
        if (
            timeFormat == (int)EMPTY_VALUE
            || timeFormat == EMPTY_VALUE
        ) timeFormat = TIME_DATE|TIME_MINUTES;
        return TimeToString(value, timeFormat);
    }

    /**
    * String overload
    */
    string FormatValueForPrinting(
        string value,
        int digits,
        int timeFormat
    ) {
        return value;
    }

    void GetBetTradesInfo(
        double &output[],
        string group,
        string symbol,
        int pool, // 0: try running trades first and then history trades, 1: try running only, 2: try history only
        bool findConsecutive = false
    ) {
        if (ArraySize(output) < 4)
        {
            ArrayResize(output, 4);
            ArrayInitialize(output, 0.0);
        }

        double lots         = output[0]; // will be the lot size of the first loaded trade
        double profitOrLoss = output[1]; // 0 is initial value, 1 is profit, -1 is loss
        double consecutive  = output[2]; // the number of consecutive profitable or losable trades
        double profit       = output[3]; // will be the profit of the first loaded trade
        bool historyTrades  = (pool == 2) ? true : false;
        
        int total = (historyTrades) ? HistoryTradesTotal() : TradesTotal();

        for (int pos = total - 1; pos >= 0; pos--)
        {
            if (
                (!historyTrades && TradeSelectByIndex(pos, "group", group, "symbol", symbol))
                || (historyTrades && HistoryTradeSelectByIndex(pos, "group", group, "symbol", symbol))
            ) {
                if (
                    ((pool == 0 || pool == 1) && TimeCurrent() - OrderOpenTime() < 3) // skip for brand new trades
                    ||
                    (
                        // exclude expired pending orders
                        !historyTrades
                        && OrderExpiration() > 0
                        && OrderExpiration() <= OrderCloseTime()
                    )
                ) {
                    continue;
                }

                if (lots == 0.0)
                {
                    lots = OrderLots();
                }

                profit = OrderClosePrice() - OrderOpenPrice();
                profit = NormalizeDouble(profit, SymbolDigits(OrderSymbol()));
                
                if (profit == 0.0)
                {
                    // Consider a trade with zero profit as non existent
                    continue;
                }

                if (IsOrderTypeSell())
                {
                    profit = -1 * profit;
                }

                if (profitOrLoss == 0)
                {
                    // We enter here only for the first trade
                    profitOrLoss = (profit < 0.0) ? -1 : 1;

                    consecutive++;

                    if (findConsecutive == false) break;
                }
                else
                {
                    // For the trades after the first one, if its profit is the opposite of profitOrLoss, we need to break
                    if (
                        (profitOrLoss > 0.0 && profit < 0.0)
                        || (profitOrLoss < 0.0 && profit > 0.0)
                    ) {
                        break;
                    }

                    consecutive++;
                }
            }
        }

        output[0] = lots;
        output[1] = profitOrLoss;
        output[2] = consecutive;
        output[3] = profit;
        
        if (pool == 0 && (findConsecutive || profitOrLoss == 0))
        {
            // running trades tried, continue with the history trades
            pool = 2;
            GetBetTradesInfo(output, group, symbol, pool, findConsecutive);
        }
    }

    bool HistoryTradeSelectByIndex(
        int index,
        string group_mode    = "all",
        string group         = "0",
        string market_mode   = "all",
        string market        = "",
        string BuysOrSells   = "both"
    ) {
        if (OrderSelect((int)index, SELECT_BY_POS, MODE_HISTORY) && OrderType() < 2)
        {
            if (FilterOrderBy(
                group_mode,
                group,
                market_mode,
                market,
                BuysOrSells)
            ) {
                return true;
            }
        }

        return false;
    }

    int HistoryTradesTotal(datetime from_date=0, datetime to_date=0)
    {
        // both input parameters are dummy
        // they exist only to make the function compatible with MQL5-like code

        return OrdersHistoryTotal();
    }

    template<typename T>
    bool InArray(T &array[], T value)
    {
        int size = ArraySize(array);

        if (size > 0)
        {
            for (int i = 0; i < size; i++)
            {
                if (array[i] == value)
                {
                    return true;
                }
            }
        }

        return false;
    }

    bool IsOrderTypeBuy()
    {
        int type = OrderType();

        return (type == OP_BUY || type == OP_BUYSTOP || type == OP_BUYLIMIT);
    }

    bool IsOrderTypeSell()
    {
        int type = OrderType();

        return (type == OP_SELL || type == OP_SELLSTOP || type == OP_SELLLIMIT);
    }

    bool ModifyOrder(
        long ticket,
        double op,
        double sll = 0,
        double tpl = 0,
        double slp = 0,
        double tpp = 0,
        datetime exp = 0,
        color clr = clrNONE,
        bool ontrade_event = true
    ) {
        int bs = 1;

        if (
            OrderType() == OP_SELL
            || OrderType() == OP_SELLSTOP
            || OrderType() == OP_SELLLIMIT
        )
        {bs = -1;} // Positive when Buy, negative when Sell

        while (true)
        {
            uint time0 = GetTickCount();

            WaitTradeContextIfBusy();

            if (!OrderSelect((int)ticket, SELECT_BY_TICKET))
            {
                return false;
            }

            string symbol      = OrderSymbol();
            int type           = OrderType();
            double ask         = SymbolInfoDouble(symbol, SYMBOL_ASK);
            double bid         = SymbolInfoDouble(symbol, SYMBOL_BID);
            int digits         = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
            double point       = SymbolInfoDouble(symbol, SYMBOL_POINT);
            double stoplevel   = point * SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL);
            double freezelevel = point * SymbolInfoInteger(symbol, SYMBOL_TRADE_FREEZE_LEVEL);

            if (OrderType() < 2) {op = OrderOpenPrice();} else {op = NormalizeDouble(op,digits);}

            sll = NormalizeDouble(sll, digits);
            tpl = NormalizeDouble(tpl, digits);

            if (op < 0 || op >= EMPTY_VALUE || sll < 0 || slp < 0 || tpl < 0 || tpp < 0)
            {
                break;
            }
            
            //-- OP -----------------------------------------------------------
            // https://book.mql4.com/appendix/limits
            if (type == OP_BUYLIMIT)
            {
                if (ask - op < stoplevel) {op = ask - stoplevel;}
                if (ask - op <= freezelevel) {op = ask - freezelevel - point;}
            }
            else if (type == OP_BUYSTOP)
            {
                if (op - ask < stoplevel) {op = ask + stoplevel;}
                if (op - ask <= freezelevel) {op = ask + freezelevel + point;}
            }
            else if (type == OP_SELLLIMIT)
            {
                if (op - bid < stoplevel) {op = bid + stoplevel;}
                if (op - bid <= freezelevel) {op = bid + freezelevel + point;}
            }
            else if (type == OP_SELLSTOP)
            {
                if (bid - op < stoplevel) {op = bid - stoplevel;}
                if (bid - op < freezelevel) {op = bid - freezelevel - point;}
            }

            op = NormalizeDouble(op, digits);

            //-- SL and TP ----------------------------------------------------
            double sl = 0, tp = 0, vsl = 0, vtp = 0;

            sl = AlignStopLoss(symbol, type, op, attrStopLoss(), sll, slp);

            if (sl < 0) {break;}

            tp = AlignTakeProfit(symbol, type, op, attrTakeProfit(), tpl, tpp);

            if (tp < 0) {break;}

            if (USE_VIRTUAL_STOPS)
            {
                //-- virtual SL and TP --------------------------------------------
                vsl = sl;
                vtp = tp;
                sl = 0;
                tp = 0;

                double askbid = ask;
                if (bs < 0) {askbid = bid;}

                if (vsl > 0 || USE_EMERGENCY_STOPS == "always")
                {
                    if (EMERGENCY_STOPS_REL > 0 || EMERGENCY_STOPS_ADD > 0)
                    {
                        sl = vsl - EMERGENCY_STOPS_REL*MathAbs(askbid-vsl)*bs;

                        if (sl <= 0) {sl = askbid;}

                        sl = sl - toDigits(EMERGENCY_STOPS_ADD,symbol)*bs;
                    }
                }

                if (vtp > 0 || USE_EMERGENCY_STOPS == "always")
                {
                    if (EMERGENCY_STOPS_REL > 0 || EMERGENCY_STOPS_ADD > 0)
                    {
                        tp = vtp + EMERGENCY_STOPS_REL*MathAbs(vtp-askbid)*bs;

                        if (tp <= 0) {tp = askbid;}

                        tp = tp + toDigits(EMERGENCY_STOPS_ADD,symbol)*bs;
                    }
                }

                vsl = NormalizeDouble(vsl,digits);
                vtp = NormalizeDouble(vtp,digits);
            }

            sl = NormalizeDouble(sl,digits);
            tp = NormalizeDouble(tp,digits);

            //-- modify -------------------------------------------------------
            ResetLastError();
            
            if (USE_VIRTUAL_STOPS)
            {
                if (vsl != attrStopLoss() || vtp != attrTakeProfit())
                {
                    VirtualStopsDriver("set", ticket, vsl, vtp, toPips(MathAbs(op-vsl), symbol), toPips(MathAbs(vtp-op), symbol));
                }
            }

            bool success = false;

            if (
                (OrderType() > 1 && op != NormalizeDouble(OrderOpenPrice(),digits))
                || sl != NormalizeDouble(OrderStopLoss(),digits)
                || tp != NormalizeDouble(OrderTakeProfit(),digits)
                || exp != OrderExpirationTime()
            ) {
                success = OrderModify((int)ticket, op, sl, tp, exp, clr);
            }

            //-- error check --------------------------------------------------
            int erraction = CheckForTradingError(GetLastError(), "Modify error");

            switch(erraction)
            {
                case 0: break;    // no error
                case 1: continue; // overcomable error
                case 2: break;    // fatal error
            }

            //-- finish work --------------------------------------------------
            if (success == true)
            {
                if (!IsTesting() && !IsVisualMode())
                {
                    Print("Operation details: Speed " + (string)(GetTickCount()-time0) + " ms");
                }

                if (ontrade_event == true)
                {
                    OrderModified(ticket);
                    OnTrade();
                }

                if (OrderSelect((int)ticket,SELECT_BY_TICKET)) {}

                return true;
            }

            break;
        }

        return false;
    }

    int OCODriver()
    {
        static int last_known_ticket = 0;
    static int orders1[];
    static int orders2[];
    int i, size;
    
    int total = OrdersTotal();
    
    for (int pos=total-1; pos>=0; pos--)
    {
        if (OrderSelect(pos,SELECT_BY_POS,MODE_TRADES))
        {
            int ticket = OrderTicket();
            
            //-- end here if we reach the last known ticket
            if (ticket == last_known_ticket) {break;}
            
            //-- set the last known ticket, only if this is the first iteration
            if (pos == total-1) {
                last_known_ticket = ticket;
            }
            
            //-- we are searching for pending orders, skip trades
            if (OrderType() <= OP_SELL) {continue;}
            
            //--
            if (StringSubstr(OrderComment(), 0, 5) == "[oco:")
            {
                int ticket_oco = StrToInteger(StringSubstr(OrderComment(), 5, StringLen(OrderComment())-1)); 
                
                bool found = false;
                size = ArraySize(orders2);
                for (i=0; i<size; i++)
                {
                if (orders2[i] == ticket_oco) {
                    found = true;
                    break;
                }
                }
                
                if (found == false) {
                ArrayResize(orders1, size+1);
                ArrayResize(orders2, size+1);
                orders1[size] = ticket_oco;
                orders2[size] = ticket;
                }
            }
        }
    }
    
    size = ArraySize(orders1);
    int dbremove = false;
    for (i=size-1; i>=0; i--)
    {
        if (OrderSelect(orders1[i], SELECT_BY_TICKET, MODE_TRADES) == false || OrderType() <= OP_SELL)
        {
            if (OrderSelect(orders2[i], SELECT_BY_TICKET, MODE_TRADES)) {
                if (DeleteOrder(orders2[i],clrWhite))
                {
                dbremove = true;
                }
            }
            else {
                dbremove = true;
            }
            
            if (dbremove == true)
            {
                ArrayStripKey(orders1, i);
                ArrayStripKey(orders2, i);
            }
        }
    }
    
    size = ArraySize(orders2);
    dbremove = false;
    for (i=size-1; i>=0; i--)
    {
        if (OrderSelect(orders2[i], SELECT_BY_TICKET, MODE_TRADES) == false || OrderType() <= OP_SELL)
        {
            if (OrderSelect(orders1[i], SELECT_BY_TICKET, MODE_TRADES)) {
                if (DeleteOrder(orders1[i],clrWhite))
                {
                dbremove = true;
                }
            }
            else {
                dbremove = true;
            }
            
            if (dbremove == true)
            {
                ArrayStripKey(orders1, i);
                ArrayStripKey(orders2, i);
            }
        }
    }
    
    return true;
    }

    bool OnTimerSet(double seconds)
    {
    if (FXD_ONTIMER_TAKEN)
    {
        if (seconds<=0) {
            FXD_ONTIMER_TAKEN_IN_MILLISECONDS = false;
            FXD_ONTIMER_TAKEN_TIME = 0;
        }
        else if (seconds < 1) {
            FXD_ONTIMER_TAKEN_IN_MILLISECONDS = true;
            FXD_ONTIMER_TAKEN_TIME = seconds*1000; 
        }
        else {
            FXD_ONTIMER_TAKEN_IN_MILLISECONDS = false;
            FXD_ONTIMER_TAKEN_TIME = seconds;
        }
        
        return true;
    }

    if (seconds<=0) {
        EventKillTimer();
    }
    else if (seconds < 1) {
        return (EventSetMillisecondTimer((int)(seconds*1000)));  
    }
    else {
        return (EventSetTimer((int)seconds));
    }
    
    return true;
    }

    class OnTradeEventDetector
    {
    private:
        //--- structures
        struct EventValues
        {
            // special fields
            string   reason,
                    detail;

            // order related fields
            long     magic,
                    ticket;
            int      type;
            datetime timeClose,
                    timeOpen,
                    timeExpiration;
            double   commission,
                    priceOpen,
                    priceClose,
                    profit,
                    stopLoss,
                    swap,
                    takeProfit,
                    volume;
            string   comment,
                    symbol;
        };
        
        struct Position
        {
            int type;
            long     magic,
                    ticket;
            datetime timeClose,
                    timeExpiration,
                    timeOpen;
            double   commission,
                    priceCurrent,
                    priceOpen,
                    profit,
                    stopLoss,
                    swap,
                    takeProfit,
                    volume;
            string   comment,
                    symbol;
        };

        struct PendingOrder
        {
            int type;
            long     magic,
                    ticket;
            datetime timeClose,
                    timeExpiration,
                    timeOpen;
            double   priceCurrent,
                    priceOpen,
                    stopLoss,
                    takeProfit,
                    volume;
            string   comment,
                    symbol;
        };
        
        struct PositionExpirationTimes
        {
            long ticket;
            datetime timeExpiration;
        };
        
        //--- variables and arrays
        bool debug;
        
        // Because we can have multiple new events at once, the idea is
        // to run the detector repeatedly until no new event is detected.
        // When this variable is true, it means that the event detection
        // is repeated. It should stop repeating when no new event is detected.
        bool isRepeat;

        int eventValuesQueueIndex;
        EventValues eventValues[];

        PendingOrder previousPendingOrders[];
        PendingOrder pendingOrders[];

        Position previousPositions[];
        Position positions[];

        PositionExpirationTimes positionExpirationTimes[];

        //--- methods
        
        /**
        * Like ArrayCopy(), but for any type.
        */
        template<typename T>
        void CopyList(T &dest[], T &src[])
        {
            int size = ArraySize(src);
            ArrayResize(dest, size);

            for (int i = 0; i < size; i++)
            {
                dest[i] = src[i];
            }
        }

        /**
        * Overloaded method 1 of 2
        */
        int MakeListOf(PendingOrder &list[])
        {
            ArrayResize(list, 0);

            int count        = OrdersTotal();
            int howManyAdded = 0;

            for (int index = 0; index < count; index++)
            {
                if (OrderSelect(index, SELECT_BY_POS) == false) continue;
                if (OrderType() < OP_BUYLIMIT) continue;

                howManyAdded++;
                ArrayResize(list, howManyAdded);
                int i = howManyAdded - 1;

                // int
                list[i].type   = OrderType();
                list[i].magic  = OrderMagicNumber();
                list[i].ticket = OrderTicket();

                // datetime
                list[i].timeClose      = OrderCloseTime();
                list[i].timeExpiration = OrderExpiration();
                list[i].timeOpen       = OrderOpenTime();

                // double
                list[i].priceCurrent = OrderClosePrice();
                list[i].priceOpen    = OrderOpenPrice();
                list[i].stopLoss     = OrderStopLoss();
                list[i].takeProfit   = OrderTakeProfit();
                list[i].volume       = OrderLots();

                // string
                list[i].comment = OrderComment();
                list[i].symbol  = OrderSymbol();
            }

            return howManyAdded;
        }

        /**
        * Overloaded method 2 of 2
        */
        int MakeListOf(Position &list[])
        {
            ArrayResize(list, 0);

            int count        = OrdersTotal();
            int howManyAdded = 0;

            for (int index = 0; index < count; index++)
            {
                if (OrderSelect(index, SELECT_BY_POS) == false) continue;
                if (OrderType() > OP_SELL) continue;

                howManyAdded++;
                ArrayResize(list, howManyAdded);
                int i = howManyAdded - 1;

                // int
                list[i].type   = OrderType();
                list[i].magic  = OrderMagicNumber();
                list[i].ticket = OrderTicket();

                // datetime
                list[i].timeClose      = OrderCloseTime();
                list[i].timeExpiration = (datetime)0;
                list[i].timeOpen       = OrderOpenTime();

                // double
                list[i].commission   = OrderCommission();
                list[i].priceCurrent = OrderClosePrice();
                list[i].priceOpen    = OrderOpenPrice();
                list[i].profit       = OrderProfit();
                list[i].stopLoss     = OrderStopLoss();
                list[i].swap         = OrderSwap();
                list[i].takeProfit   = OrderTakeProfit();
                list[i].volume       = OrderLots();

                // string
                list[i].comment = OrderComment();
                list[i].symbol  = OrderSymbol();
                
                // extract expiration
                list[i].timeExpiration = expirationWorker.GetExpiration(list[i].ticket);

                if (USE_VIRTUAL_STOPS)
                {
                    list[i].stopLoss   = VirtualStopsDriver("get sl", list[i].ticket);
                    list[i].takeProfit = VirtualStopsDriver("get tp", list[i].ticket);
                }
            }

            return howManyAdded;
        }

        /**
        * This method loops through 2 lists of items and finds a difference. This difference is the event.
        * "Items" are either pending orders or positions.
        *
        * Returns true if an event is detected or false if not.
        */
        template<typename ITEMS_TYPE> 
        bool DetectEvent(ITEMS_TYPE &previousItems[], ITEMS_TYPE &currentItems[])
        {
            ITEMS_TYPE item;
            string reason   = "";
            string detail   = "";
            int countBefore = ArraySize(previousItems);
            int countNow    = ArraySize(currentItems);

            // closed
            if (reason == "") {
                for (int index = 0; index < countBefore; index++) {
                    item = FindMissingItem(previousItems, currentItems);

                    if (item.ticket > 0) {
                        DeleteItem(previousItems, item);
                        reason = "close";

                        break;
                    }
                }
            }

            // new
            if (reason == "") {
                for (int index = 0; index < countNow; index++) {
                    item = FindMissingItem(currentItems, previousItems);

                    if (item.ticket > 0) {
                        if (
                            item.type < 2 // it's a running trade
                            && item.ticket != attrTicketParent(item.ticket)
                        ) {
                            // In MQL4: When a trade is closed partially, the ticket changes.
                            // The original (parent) trade is closed and a new one is created,
                            // with a different ticket.
                            reason = "decrement";
                        }
                        else {
                            reason = "new";
                        }

                        PushItem(previousItems, item);

                        break;
                    }
                }
            }

            // modified
            if (reason == "") {
                if (countBefore != countNow) {
                    Print("OnTrade event detector: Uncovered situation reached");
                }

                for (int index = 0; index < countNow; index++) {
                    int previousIndex = -1;

                    ITEMS_TYPE current = currentItems[index];
                    ITEMS_TYPE previous;
                    previous.ticket = 0;

                    for (int j = 0; j < countBefore; j++) {
                        if (current.ticket == previousItems[j].ticket) {
                            previousIndex = j;
                            previous = previousItems[j];

                            break;
                        }
                    }

                    if (current.ticket != previous.ticket) {
                        Print("OnTrade event detector: Uncovered situation reached (2)");
                    }

                    if (previous.volume < current.volume) {
                        previousItems[previousIndex].volume = current.volume;
                        item = previousItems[previousIndex];

                        reason = "increment";

                        break;
                    }

                    if (previous.volume > current.volume) {
                        previousItems[previousIndex].volume = current.volume;
                        item = previousItems[previousIndex];

                        reason = "decrement";

                        break;
                    }

                    if (
                        previous.stopLoss != current.stopLoss
                        && previous.takeProfit != current.takeProfit
                    ) {
                        previousItems[previousIndex].stopLoss = current.stopLoss;
                        previousItems[previousIndex].takeProfit = current.takeProfit;
                        item = previousItems[previousIndex];

                        reason = "modify";
                        detail = "sltp";

                        break;
                    }
                    // SL modified
                    else if (previous.stopLoss != current.stopLoss) {
                        previousItems[previousIndex].stopLoss = current.stopLoss;
                        item = previousItems[previousIndex];

                        reason = "modify";
                        detail = "sl";

                        break;
                    }
                    // TP modified
                    else if (previous.takeProfit != current.takeProfit) {
                        previousItems[previousIndex].takeProfit = current.takeProfit;
                        item = previousItems[previousIndex];

                        reason = "modify";
                        detail = "tp";

                        break;
                    }

                    if (previous.timeExpiration != current.timeExpiration) {
                        previousItems[previousIndex].timeExpiration = current.timeExpiration;
                        item = previousItems[previousIndex];

                        reason = "modify";
                        detail = "expiration";

                        break;
                    }
                }
            }

            if (reason == "")
            {
                return false;
            }

            UpdateValues(item, reason, detail);

            return true;
        }
        
        /**
        * From the source list of orders or positions, find the item that is missing
        * in the target list of orders or positions. The searching is by the item's ticket.
        *
        * If all items from the source list exist in the target list, return an empty item with ticket 0.
        * If for some item in source list there is no item in the target list, return that source item.
        */
        template<typename T> 
        T FindMissingItem(T &source[], T &target[])
        {
            int sourceCount = ArraySize(source);
            int targetCount  = ArraySize(target);
            T item;
            item.ticket = 0;

            long ticket = 0;

            for (int i = 0; i < sourceCount; i++)
            {
                bool found = false;

                for (int j = 0; j < targetCount; j++)
                {
                    if (source[i].ticket == target[j].ticket)
                    {
                        found = true;
                        break;
                    }
                }

                if (found == false)
                {
                    item = source[i];
                    break;
                }
            }

            return item;
        }

        /**
        * From the list of previous orders or positions, find and remove the
        * provided item.
        */
        template<typename T> 
        bool DeleteItem(T &list[], T &item)
        {
            int listCount = ArraySize(list);
            bool removed = false;

            for (int i = 0; i < listCount; i++)
            {
                if (list[i].ticket == item.ticket) {
                    ArrayStripKey(list, i);
                    removed = true;

                    break;
                }
            }

            return removed;
        }

        /**
        * Push a new item in the list
        */
        template<typename T> 
        void PushItem(T &list[], T &item)
        {
            int listCount = ArraySize(list);

            ArrayResize(list, listCount + 1);

            list[listCount] = item;
        }

        /**
        * Overloaded method 1 of 2
        */
        void UpdateValues(Position &item, string reason, string detail)
        {
            long ticket        = item.ticket;
            datetime timeOpen  = item.timeOpen;
            datetime timeClose = item.timeClose;
            double priceOpen   = item.priceOpen;
            double priceClose  = item.priceCurrent;
            double profit      = item.profit;
            double swap        = item.swap;
            double commission  = item.commission;
            double volume      = item.volume;

            if (reason == "close" || reason == "decrement")
            {
                if (OrderSelect((int)ticket, SELECT_BY_TICKET, MODE_HISTORY))
                {
                    timeOpen   = OrderOpenTime();
                    timeClose  = OrderCloseTime();
                    priceOpen  = OrderOpenPrice();
                    priceClose = OrderClosePrice();
                    profit     = OrderProfit();
                    swap       = OrderSwap();
                    commission = OrderCommission();
                    volume     = OrderLots();

                    if (detail == "")
                    {
                        if (
                            item.timeExpiration > 0
                            && item.timeExpiration <= timeClose
                        ) {
                            detail = "expiration";
                        }
                    }

                    if (detail == "")
                    {
                        string comment = OrderComment();

                        // Try with comments, which works in the Tester, but it could not work in real
                            if (comment == "[tp]") detail = "tp";
                        else if (comment == "[sl]") detail = "sl";

                        // Try to detect close by SL or TP by the close price
                        if (detail == "")
                        {
                            int type = item.type;

                            double sl = OrderStopLoss();
                            double tp = OrderTakeProfit();

                            if (type == 0) // BUY
                            {
                                    if (sl > 0 && priceClose <= sl) detail = "sl";
                                else if (tp > 0 && priceClose >= tp) detail = "tp";
                            }
                            else if (type == 1) // SELL
                            {
                                    if (sl > 0 && priceClose >= sl) detail = "sl";
                                else if (tp > 0 && priceClose <= tp) detail = "tp";
                            }
                        }
                    }
                }
            }

            int i = eventValuesQueueIndex;

            eventValues[i].reason = reason;
            eventValues[i].detail = detail;
    
            eventValues[i].priceClose     = priceClose;
            eventValues[i].timeClose      = timeClose;
            eventValues[i].comment        = item.comment;
            eventValues[i].commission     = commission;
            eventValues[i].timeExpiration = item.timeExpiration;
            eventValues[i].volume         = volume;
            eventValues[i].magic          = item.magic;
            eventValues[i].priceOpen      = priceOpen;
            eventValues[i].timeOpen       = timeOpen;
            eventValues[i].profit         = profit;
            eventValues[i].stopLoss       = item.stopLoss;
            eventValues[i].swap           = swap;
            eventValues[i].symbol         = item.symbol;
            eventValues[i].takeProfit     = item.takeProfit;
            eventValues[i].ticket         = ticket;
            eventValues[i].type           = item.type;

            if (debug)
            {
                PrintUpdatedValues();
            }
        }
        
        /**
        * Overloaded method 2 of 2
        */
        void UpdateValues(PendingOrder &item, string reason, string detail)
        {
            int i = eventValuesQueueIndex;

            eventValues[i].reason = reason;
            eventValues[i].detail = detail;

            eventValues[i].priceClose     = item.priceCurrent;
            eventValues[i].timeClose      = item.timeClose;
            eventValues[i].comment        = item.comment;
            eventValues[i].commission     = 0.0;
            eventValues[i].timeExpiration = item.timeExpiration;
            eventValues[i].volume         = item.volume;
            eventValues[i].magic          = item.magic;
            eventValues[i].priceOpen      = item.priceOpen;
            eventValues[i].timeOpen       = item.timeOpen;
            eventValues[i].profit         = 0.0;
            eventValues[i].stopLoss       = item.stopLoss;
            eventValues[i].swap           = 0.0;
            eventValues[i].symbol         = item.symbol;
            eventValues[i].takeProfit     = item.takeProfit;
            eventValues[i].ticket         = item.ticket;
            eventValues[i].type           = item.type;

            if (debug)
            {
                PrintUpdatedValues();
            }
        }

        void PrintUpdatedValues()
        {
            Print(
                " <<<"
            );
            
            Print(
                " | reason: ", e_Reason(),
                " | detail: ", e_ReasonDetail(),
                " | ticket: ", e_attrTicket(),
                " | type: ", EnumToString((ENUM_ORDER_TYPE)e_attrType())
            );
            
            Print(
                " | openTime : ", e_attrOpenTime(),
                " | openPrice : ", e_attrOpenPrice()
            );
            
            Print(
                " | closeTime: ", e_attrCloseTime(),
                " | closePrice: ", e_attrClosePrice()
            );
            
            Print(
                " | volume: ", e_attrLots(),
                " | sl: ", e_attrStopLoss(),
                " | tp: ", e_attrTakeProfit(),
                " | profit: ", e_attrProfit(),
                " | swap: ", e_attrSwap(),
                " | exp: ", e_attrExpiration(),
                " | comment: ", e_attrComment()
            );
            
            Print(
                ">>>"
            );
        }

        int AddEventValues()
        {
            eventValuesQueueIndex++;
            ArrayResize(eventValues, eventValuesQueueIndex + 1);

            return eventValuesQueueIndex;
        }

        int RemoveEventValues()
        {
            if (eventValuesQueueIndex == -1)
            {
                Print("Cannot remove event values, add them first. (in function ", __FUNCTION__, ")");
            }
            else
            {
                eventValuesQueueIndex--;
                ArrayResize(eventValues, eventValuesQueueIndex + 1);
            }

            return eventValuesQueueIndex;
        }

    public:
        /**
        * Default constructor
        */
        OnTradeEventDetector(void)
        {
            debug = false;
            isRepeat = false;
            eventValuesQueueIndex = -1;
        };

        bool Start()
        {
            AddEventValues();

            if (isRepeat == false) {
                MakeListOf(pendingOrders);
                MakeListOf(positions);
            }

            bool success = false;

            if (!success) success = DetectEvent(previousPendingOrders, pendingOrders);

            if (!success) success = DetectEvent(previousPositions, positions);

            //CopyList(previousPendingOrders, pendingOrders);
            //CopyList(previousPositions, positions);

            isRepeat = success; // Repeat until no success

            return success;
        }

        void End()
        {
            RemoveEventValues();
        }

        string EventValueReason() {return eventValues[eventValuesQueueIndex].reason;}
        string EventValueDetail() {return eventValues[eventValuesQueueIndex].detail;}

        int EventValueType() {return eventValues[eventValuesQueueIndex].type;}

        datetime EventValueTimeClose()      {return eventValues[eventValuesQueueIndex].timeClose;}
        datetime EventValueTimeOpen()       {return eventValues[eventValuesQueueIndex].timeOpen;}
        datetime EventValueTimeExpiration() {return eventValues[eventValuesQueueIndex].timeExpiration;}

        long EventValueMagic()  {return eventValues[eventValuesQueueIndex].magic;}
        long EventValueTicket() {return eventValues[eventValuesQueueIndex].ticket;}

        double EventValueCommission() {return eventValues[eventValuesQueueIndex].commission;}
        double EventValuePriceOpen()  {return eventValues[eventValuesQueueIndex].priceOpen;}
        double EventValuePriceClose() {return eventValues[eventValuesQueueIndex].priceClose;}
        double EventValueProfit()     {return eventValues[eventValuesQueueIndex].profit;}
        double EventValueStopLoss()   {return eventValues[eventValuesQueueIndex].stopLoss;}
        double EventValueSwap()       {return eventValues[eventValuesQueueIndex].swap;}
        double EventValueTakeProfit() {return eventValues[eventValuesQueueIndex].takeProfit;}
        double EventValueVolume()     {return eventValues[eventValuesQueueIndex].volume;}

        string EventValueComment() {return eventValues[eventValuesQueueIndex].comment;}
        string EventValueSymbol()  {return eventValues[eventValuesQueueIndex].symbol;}
    };

    OnTradeEventDetector onTradeEventDetector;

    /**
    * When a trade is a child, its Open Price is the same as the Open Price of the most parent trade.
    * This function will return the actual Open Price of this parent trade, which would be the Close
    * Price of the previous child trade, or the parent trade if this is the only child, or itself if
    * it's the trade is not a child.
    */
    double OrderChildOpenPrice() {
        int ticket     = OrderTicket();
        int prevTicket = attrTicketPreviousSibling(ticket);

        double openPrice = 0;

        if (ticket == prevTicket) {
            openPrice = OrderOpenPrice();
        }
        else {
            double prevClosePrice = 0;
            datetime prevCloseTime = 0;
            
            if (OrderSelect(prevTicket, SELECT_BY_TICKET, MODE_HISTORY)) {
                prevClosePrice = OrderClosePrice();
                prevCloseTime = OrderCloseTime();
            }
            
            bool success = OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES);
            
            openPrice = (prevCloseTime > 0)
                ? prevClosePrice    // partial close
                : OrderOpenPrice(); // added to volume
        }
        
        return openPrice;
    }

    int OrderCreate(
        string   symbol     = "",
        int      type       = OP_BUY,
        double   lots       = 0,
        double   op         = 0,
        double   sll        = 0, // SL level
        double   tpl        = 0, // TO level
        double   slp        = 0, // SL adjust in points
        double   tpp        = 0, // TP adjust in points
        double   slippage   = 0,
        int      magic      = 0,
        string   comment    = "",
        color    arrowcolor = CLR_NONE,
        datetime expiration = 0,
        bool     oco        = false
        )
    {
        uint time0 = GetTickCount(); // used to measure speed of execution of the order

        int ticket = -1;
        bool placeExpirationObject = false; // whether or not to create an object for expiration for trades

        // calculate buy/sell flag (1 when Buy or -1 when Sell)
        int bs = 1;

        if (
            type == OP_SELL
            || type == OP_SELLSTOP
            || type == OP_SELLLIMIT
            )
        {
            bs = -1;
        }

        if (symbol == "") {symbol = Symbol();}

        lots = AlignLots(symbol, lots);

        int digits = 0;
        double ask = 0, bid = 0, point = 0, ticksize = 0;
        double sl = 0, tp = 0;
        double vsl = 0, vtp = 0;

        //-- attempt to send trade/order -------------------------------------
        while (!IsStopped())
        {
            WaitTradeContextIfBusy();

            static bool not_allowed_message = false;

            if (
                !MQLInfoInteger(MQL_TESTER)
                && !MarketInfo(symbol, MODE_TRADEALLOWED)
            ) {
                if (not_allowed_message == false)
                {
                    Print("Market ("+symbol+") is closed");
                }

                not_allowed_message = true;

                return false;
            }

            not_allowed_message = false;

            digits   = (int)MarketInfo(symbol, MODE_DIGITS);
            ask      = MarketInfo(symbol, MODE_ASK);
            bid      = MarketInfo(symbol, MODE_BID);
            point    = MarketInfo(symbol, MODE_POINT);
            ticksize = MarketInfo(symbol, MODE_TICKSIZE);

            //- not enough money check: fix maximum possible lot by margin required, or quit
            if (type==OP_BUY || type==OP_SELL)
            {
                double LotStep          = MarketInfo(symbol,MODE_LOTSTEP);
                double MinLots          = MarketInfo(symbol,MODE_MINLOT);
                double margin_required  = MarketInfo(symbol,MODE_MARGINREQUIRED);
                static bool not_enough_message = false;

                if (margin_required != 0)
                {
                    double max_size_by_margin = AccountFreeMargin() / margin_required;

                    if (lots > max_size_by_margin)
                    {
                        double size_old = lots;
                        lots = max_size_by_margin;

                        if (lots < MinLots)
                        {
                            if (not_enough_message == false)
                            {
                                Print("Not enough money to trade :( The robot is still working, waiting for some funds to appear...");
                            }

                            not_enough_message = true;
                            return false;
                        }
                        else
                        {
                            lots = MathFloor(lots / LotStep) * LotStep;

                            Print("Not enough money to trade " + DoubleToString(size_old, 2)+", the volume to trade will be the maximum possible of " + DoubleToString(lots, 2));
                        }
                    }
                }

                not_enough_message = false;
            }

            // fix the comment, because it seems that the comment is deleted if its lenght is > 31 symbols
            if (StringLen(comment) > 31)
            {
                comment = StringSubstr(comment,0,31);
            }

            //- expiration for trades
            if (type == OP_BUY || type == OP_SELL)
            {
                if (expiration > 0)
                {
                    //- bo broker?
                    if (
                        StringLen(symbol) > 6
                        && StringSubstr(symbol, StringLen(symbol) - 2) == "bo"
                    ) {
                        //- convert UNIX to seconds
                        if (expiration > TimeCurrent()-100) {
                            expiration = expiration - TimeCurrent();
                        }

                        comment = "BO exp:" + (string)expiration;
                    }
                    else
                    {
                        // The expiration in this case is a vertical line
                        // Comment doesn't always work,
                        // because it changes when the trade is partially closed
                        placeExpirationObject = true;
                    }
                }
            }

            if (type == OP_BUY || type == OP_SELL)
            {
                op = (bs > 0) ? ask : bid;
            }

            op  = NormalizeDouble(op, digits);
            sll = NormalizeDouble(sll, digits);
            tpl = NormalizeDouble(tpl, digits);

            if (op < 0 || op >= EMPTY_VALUE || sll < 0 || slp < 0 || tpl < 0 || tpp < 0)
            {
                break;
            }

            //-- SL and TP ----------------------------------------------------
            vsl = 0; vtp = 0;

            sl = AlignStopLoss(symbol, type, op, 0, NormalizeDouble(sll, digits), slp);

            if (sl < 0) {break;}

            tp = AlignTakeProfit(symbol, type, op, 0, NormalizeDouble(tpl, digits), tpp);

            if (tp < 0) {break;}

            if (USE_VIRTUAL_STOPS)
            {
                //-- virtual SL and TP --------------------------------------------
                vsl = sl;
                vtp = tp;
                sl = 0;
                tp = 0;

                double askbid = (bs > 0) ? ask : bid;

                if (vsl > 0 || USE_EMERGENCY_STOPS == "always")
                {
                    if (EMERGENCY_STOPS_REL > 0 || EMERGENCY_STOPS_ADD > 0)
                    {
                        sl = vsl - EMERGENCY_STOPS_REL * MathAbs(askbid - vsl) * bs;

                        if (sl <= 0) {sl = askbid;}

                        sl = sl - toDigits(EMERGENCY_STOPS_ADD, symbol) * bs;
                    }
                }

                if (vtp > 0 || USE_EMERGENCY_STOPS == "always")
                {
                    if (EMERGENCY_STOPS_REL > 0 || EMERGENCY_STOPS_ADD > 0)
                    {
                        tp = vtp + EMERGENCY_STOPS_REL * MathAbs(vtp - askbid) * bs;

                        if (tp <= 0) {tp = askbid;}

                        tp = tp + toDigits(EMERGENCY_STOPS_ADD, symbol) * bs;
                    }
                }

                vsl = NormalizeDouble(vsl, digits);
                vtp = NormalizeDouble(vtp, digits);
            }

            sl = NormalizeDouble(sl, digits);
            tp = NormalizeDouble(tp, digits);

            //-- fix expiration for pending orders ----------------------------
            datetime expirationTmp = 0;

            if (expiration > 0 && type > OP_SELL)
            {
                if ((expiration - TimeCurrent()) < (11 * 60))
                {
                    Print("Expiration time cannot be less than 11 minutes, so it was automatically modified to 11 minutes. The pending order will be deleted sooner by a virtual expiration.");
                    placeExpirationObject = true;
                    expirationTmp = expiration;
                    expiration = TimeCurrent() + (11 * 60);
                }
            }
            else if (expiration > 0 && type <= OP_SELL)
            {
                expirationTmp = expiration;
            }

            //-- fix prices by ticksize
            op = MathRound(op / ticksize) * ticksize;
            sl = MathRound(sl / ticksize) * ticksize;
            tp = MathRound(tp / ticksize) * ticksize;

            //-- send ---------------------------------------------------------
            ResetLastError();

            ticket = OrderSend(
                symbol,
                type,
                lots,
                op,
                (int)(slippage * PipValue(symbol)),
                sl,
                tp,
                comment,
                magic,
                expiration,
                arrowcolor
            );
            
            if (placeExpirationObject) {
                expiration = expirationTmp;
            }

            //-- error check --------------------------------------------------
            string msg_prefix = (type > OP_SELL) ? "New order error" : "New trade error";

            int erraction = CheckForTradingError(GetLastError(), msg_prefix);

            switch(erraction)
            {
                case 0: break;    // no error
                case 1: continue; // overcomable error
                case 2: break;    // fatal error
            }

            //-- finish work --------------------------------------------------
            if (ticket > 0)
            {
                if (USE_VIRTUAL_STOPS)
                {
                    VirtualStopsDriver("set", ticket, vsl, vtp, toPips(MathAbs(op-vsl), symbol), toPips(MathAbs(vtp-op), symbol));
                }

                //-- show some info
                double slip = 0;

                if (OrderSelect(ticket, SELECT_BY_TICKET))
                {
                    if (placeExpirationObject)
                    {
                        expirationWorker.SetExpiration(ticket, expiration);
                    }

                    if (
                        !MQLInfoInteger(MQL_TESTER)
                        && !MQLInfoInteger(MQL_VISUAL_MODE)
                        && !MQLInfoInteger(MQL_OPTIMIZATION)
                    ) {
                        slip = OrderOpenPrice() - op;

                        Print(
                            "Operation details: Speed ",
                            (GetTickCount() - time0),
                            " ms | Slippage ",
                            DoubleToStr(toPips(slip, symbol), 1),
                            " pips"
                        );
                    }
                }

                //-- fix stops in case of slippage
                if (
                    !MQLInfoInteger(MQL_TESTER)
                    && !MQLInfoInteger(MQL_VISUAL_MODE)
                    &&!MQLInfoInteger(MQL_OPTIMIZATION)
                ) {
                    slip = NormalizeDouble(OrderOpenPrice(), digits) - NormalizeDouble(op, digits);

                    if (slip != 0 && (OrderStopLoss() != 0 || OrderTakeProfit() != 0))
                    {
                        Print("Correcting stops because of slippage...");

                        sl = OrderStopLoss();
                        tp = OrderTakeProfit();

                        if (sl != 0 || tp != 0)
                        {
                            if (sl != 0) {sl = NormalizeDouble(OrderStopLoss() + slip, digits);}
                            if (tp != 0) {tp = NormalizeDouble(OrderTakeProfit() + slip, digits);}

                            ModifyOrder(ticket, OrderOpenPrice(), sl, tp, 0, 0, 0, CLR_NONE, false);
                        }
                    }
                }

                OnTrade();

                break;
            }

            break;
        }

        if (oco == true && ticket > 0)
        {
            if (USE_VIRTUAL_STOPS)
            {
                sl = vsl;
                tp = vtp;
            }

            sl = (sl > 0) ? NormalizeDouble(MathAbs(op-sl), digits) : 0;
            tp = (tp > 0) ? NormalizeDouble(MathAbs(op-tp), digits) : 0;

            int typeoco = type;

            if (typeoco == OP_BUYSTOP)
            {
                typeoco = OP_SELLSTOP;
                op = bid - MathAbs(op - ask);
            }
            else if (typeoco == OP_BUYLIMIT)
            {
                typeoco = OP_SELLLIMIT;
                op = bid + MathAbs(op - ask);
            }
            else if (typeoco == OP_SELLSTOP)
            {
                typeoco = OP_BUYSTOP;
                op = ask + MathAbs(op - bid);
            }
            else if (typeoco == OP_SELLLIMIT)
            {
                typeoco = OP_BUYLIMIT;
                op = ask - MathAbs(op - bid);
            }

            if (typeoco == OP_BUYSTOP || typeoco == OP_BUYLIMIT)
            {
                sl = (sl > 0) ? op - sl : 0;
                tp = (tp > 0) ? op + tp : 0;
                arrowcolor = clrBlue;
            }
            else
            {
                sl = (sl > 0) ? op + sl : 0;
                tp = (tp > 0) ? op - tp : 0;
                arrowcolor = clrRed;
            }

            comment = "[oco:" + (string)ticket + "]";

            OrderCreate(symbol, typeoco, lots, op, sl, tp, 0, 0, slippage, magic, comment, arrowcolor, expiration, false);
        }

        return ticket;
    }

    /**
    * This is a replacement for the system function.
    * The difference is that this can also get the expiration for trades.
    */
    datetime OrderExpiration(bool check_trade)
    {
        datetime expiration = (datetime)0;

        if (OrderType() > OP_SELL)
        {
            expiration = OrderExpiration();
        }
        else if (check_trade)
        {
            expiration = (datetime)expirationWorker.GetExpiration(OrderTicket());
        }

        return expiration;
    }

    /**
    * This is a replacement for the system function.
    * The difference is that this can also get the expiration for trades.
    */
    datetime OrderExpirationTime()
    {
        datetime expiration = (datetime)0;

        if (OrderType() > OP_SELL)
        {
            expiration = OrderExpiration();
        }
        else
        {
            expiration = (datetime)expirationWorker.GetExpiration(OrderTicket());
        }

        return expiration;
    }

    bool OrderModified(ulong ticket = 0, string action = "set")
    {
        static ulong memory[];

        if (ticket == 0)
        {
            ticket = OrderTicket();
            action = "get";
        }
        else if (ticket > 0 && action != "clear")
        {
            action = "set";
        }

        bool modified_status = InArray(memory, ticket);
        
        if (action == "get")
        {
            return modified_status;
        }
        else if (action == "set")
        {
            ArrayEnsureValue(memory, ticket);

            return true;
        }
        else if (action == "clear")
        {
            ArrayStripValue(memory, ticket);

            return true;
        }

        return false;
    }

    bool PendingOrderSelectByIndex(
        int index,
        string group_mode    = "all",
        string group         = "0",
        string market_mode   = "all",
        string market        = "",
        string BuysOrSells   = "both",
        string LimitsOrStops = "both"
    )
    {
        if (OrderSelect(index, SELECT_BY_POS, MODE_TRADES))
        {
            if (FilterOrderBy(
                group_mode,
                group,
                market_mode,
                market,
                BuysOrSells,
                LimitsOrStops,
                1)
            ) {
                return true;
            }
        }

        return false;
    }

    bool PendingOrderSelectByTicket(ulong ticket)
    {
        if (OrderSelect((int)ticket, SELECT_BY_TICKET, MODE_TRADES) && OrderType() > 1)
        {
            return true;
        }

        return false;
    }

    double PipValue(string symbol)
    {
        if (symbol == "") symbol = Symbol();

        return CustomPoint(symbol) / SymbolInfoDouble(symbol, SYMBOL_POINT);
    }

    int SecondsFromComponents(double days, double hours, double minutes, int seconds)
    {
        int retval =
            86400 * (int)MathFloor(days)
            + 3600 * (int)(MathFloor(hours) + (24 * (days - MathFloor(days))))
            + 60 * (int)(MathFloor(minutes) + (60 * (hours - MathFloor(hours))))
            + (int)((double)seconds + (60 * (minutes - MathFloor(minutes))));

        return retval;
    }

    template<typename T>
    void StringExplode(string delimiter, string inputString, T &output[])
    {
        int begin   = 0;
        int end     = 0;
        int element = 0;
        int length  = StringLen(inputString);
        int length_delimiter = StringLen(delimiter);
        T empty_val  = (typename(T) == "string") ? (T)"" : (T)0;

        if (length > 0)
        {
            while (true)
            {
                end = StringFind(inputString, delimiter, begin);

                ArrayResize(output, element + 1);
                output[element] = empty_val;
        
                if (end != -1)
                {
                    if (end > begin)
                    {
                        output[element] = (T)StringSubstr(inputString, begin, end - begin);
                    }
                }
                else
                {
                    output[element] = (T)StringSubstr(inputString, begin, length - begin);
                    break;
                }
                
                begin = end + 1 + (length_delimiter - 1);
                element++;
            }
        }
        else
        {
            ArrayResize(output, 1);
            output[element] = empty_val;
        }
    }

    template<typename T>
    string StringImplode(string delimeter, T &array[])
    {
    string retval = "";
    int size      = ArraySize(array);

    for (int i = 0; i < size; i++)
        {
        retval = StringConcatenate(retval, (string)array[i], delimeter);
    }
        
    return StringSubstr(retval, 0, (StringLen(retval) - StringLen(delimeter)));
    }

    string StringTrim(string text)
    {
    text = StringTrimRight(text);
    text = StringTrimLeft(text);
        
        return text;
    }

    double SymbolAsk(string symbol)
    {
        if (symbol == "") symbol = Symbol();

        return SymbolInfoDouble(symbol, SYMBOL_ASK);
    }

    int SymbolDigits(string symbol)
    {
        if (symbol == "") symbol = Symbol();

        return (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
    }

    double TicksData(string symbol = "", int type = 0, int shift = 0)
    {
        static bool collecting_ticks = false;
        static string symbols[];
        static int zero_sid[];
        static double memoryASK[][100];
        static double memoryBID[][100];

        int sid = 0, size = 0, i = 0, id = 0;
        double ask = 0, bid = 0, retval = 0;
        bool exists = false;

        if (ArraySize(symbols) == 0)
        {
            ArrayResize(symbols, 1);
            ArrayResize(zero_sid, 1);
            ArrayResize(memoryASK, 1);
            ArrayResize(memoryBID, 1);

            symbols[0] = _Symbol;
        }

        if (type > 0 && shift > 0)
        {
            collecting_ticks = true;
        }

        if (collecting_ticks == false)
        {
            if (type > 0 && shift == 0)
            {
                // going to get ticks
            }
            else
            {
                return 0;
            }
        }

        if (symbol == "") symbol = _Symbol;

        if (type == 0)
        {
            exists = false;
            size   = ArraySize(symbols);

            if (size == 0) {ArrayResize(symbols, 1);}

            for (i=0; i<size; i++)
            {
                if (symbols[i] == symbol)
                {
                    exists = true;
                    sid    = i;
                    break;
                }
            }

            if (exists == false)
            {
                int newsize = ArraySize(symbols) + 1;

                ArrayResize(symbols, newsize);
                symbols[newsize-1] = symbol;

                ArrayResize(zero_sid, newsize);
                ArrayResize(memoryASK, newsize);
                ArrayResize(memoryBID, newsize);

                sid=newsize;
            }

            if (sid >= 0)
            {
                ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
                bid = SymbolInfoDouble(symbol, SYMBOL_BID);

                if (bid == 0 && MQLInfoInteger(MQL_TESTER))
                {
                    Print("Ticks data collector error: " + symbol + " cannot be backtested. Only the current symbol can be backtested. The EA will be terminated.");
                    ExpertRemove();
                }

                if (
                    symbol == _Symbol
                    || ask != memoryASK[sid][0]
                    || bid != memoryBID[sid][0]
                )
                {
                    memoryASK[sid][zero_sid[sid]] = ask;
                    memoryBID[sid][zero_sid[sid]] = bid;
                    zero_sid[sid]                 = zero_sid[sid] + 1;

                    if (zero_sid[sid] == 100)
                    {
                        zero_sid[sid] = 0;
                    }
                }
            }
        }
        else
        {
            if (shift <= 0)
            {
                if (type == SYMBOL_ASK)
                {
                    return SymbolInfoDouble(symbol, SYMBOL_ASK);
                }
                else if (type == SYMBOL_BID)
                {
                    return SymbolInfoDouble(symbol, SYMBOL_BID); 
                }
                else
                {
                    double mid = ((SymbolInfoDouble(symbol, SYMBOL_ASK) + SymbolInfoDouble(symbol, SYMBOL_BID)) / 2);

                    return mid;
                }
            }
            else
            {
                size = ArraySize(symbols);

                for (i = 0; i < size; i++)
                {
                    if (symbols[i] == symbol)
                    {
                        sid = i;
                    }
                }

                if (shift < 100)
                {
                    id = zero_sid[sid] - shift - 1;

                    if(id < 0) {id = id + 100;}

                    if (type == SYMBOL_ASK)
                    {
                        retval = memoryASK[sid][id];

                        if (retval == 0)
                        {
                            retval = SymbolInfoDouble(symbol, SYMBOL_ASK);
                        }
                    }
                    else if (type == SYMBOL_BID)
                    {
                        retval = memoryBID[sid][id];

                        if (retval == 0)
                        {
                            retval = SymbolInfoDouble(symbol, SYMBOL_BID);
                        }
                    }
                }
            }
        }

        return retval;
    }

    int TicksPerSecond(bool get_max = false, bool set = false)
    {
        static datetime time0 = 0;
        static int ticks      = 0;
        static int tps        = 0;
        static int tpsmax     = 0;

        datetime time1 = TimeLocal();

        if (set == true)
        {
            if (time1 > time0)
            {
                if (time1 - time0 > 1)
                {
                    tps = 0;
                }
                else
                {
                    tps = ticks;
                }

                time0 = time1;
                ticks = 0;
            }

            ticks++;

            if (tps > tpsmax) {tpsmax = tps;}
        }

        if (get_max)
        {
            return tpsmax;
        }

        return tps;
    }

    datetime TimeAtStart(string cmd = "server")
    {
        static datetime local  = 0;
        static datetime server = 0;

        if (cmd == "local")
        {
            return local;
        }
        else if (cmd == "server")
        {
            return server;
        }
        else if (cmd == "set")
        {
            local  = TimeLocal();
            server = TimeCurrent();
        }

        return 0;
    }

    datetime TimeFromComponents(
        int time_src = 0,
        int    y = 0,
        int    m = 0,
        double d = 0,
        double h = 0,
        double i = 0,
        int    s = 0
    ) {
        MqlDateTime tm;
        int offset = 0;

        if (time_src == 0) {
            TimeCurrent(tm);
        }
        else if (time_src == 1) {
            TimeLocal(tm); 
            offset = (int)(TimeLocal() - TimeCurrent());
        }
        else if (time_src == 2) {
            TimeGMT(tm);
            offset = (int)(TimeGMT() - TimeCurrent());
        }

        if (y > 0)
        {
            if (y < 100) {y = 2000 + y;}
            tm.year = y;
        }
        if (m > 0) {tm.mon = m;}
        if (d > 0) {tm.day = (int)MathFloor(d);}

        tm.hour = (int)(MathFloor(h) + (24 * (d - MathFloor(d))));
        tm.min  = (int)(MathFloor(i) + (60 * (h - MathFloor(h))));
        tm.sec  = (int)((double)s + (60 * (i - MathFloor(i))));
        
        datetime time = StructToTime(tm) - offset;

        return time;
    }

    bool TradeSelectByIndex(
        int index,
        string group_mode    = "all",
        string group         = "0",
        string market_mode   = "all",
        string market        = "",
        string BuysOrSells   = "both"
    ) {
        if (OrderSelect((int)index, SELECT_BY_POS, MODE_TRADES) && OrderType() < 2)
        {
            if (FilterOrderBy(
                group_mode,
                group,
                market_mode,
                market,
                BuysOrSells,
                "both",
                0)
            ) {
                return true;
            }
        }

        return false;
    }

    bool TradeSelectByTicket(ulong ticket)
    {
        if (OrderSelect((int)ticket, SELECT_BY_TICKET, MODE_TRADES) && OrderType() < 2)
        {
            return true;
        }

        return false;
    }

    int TradesTotal()
    {
        return OrdersTotal();
    }

    double VirtualStopsDriver(
        string command = "",
        ulong ti       = 0,
        double sl      = 0,
        double tp      = 0,
        double slp     = 0,
        double tpp     = 0
    )
    {
        static bool initialized     = false;
        static string name          = "";
        static string loop_name[2]  = {"sl", "tp"};
        static color  loop_color[2] = {DeepPink, DodgerBlue};
        static double loop_price[2] = {0, 0};
        static ulong mem_to_ti[]; // tickets
        static int mem_to[];      // timeouts
        static bool trade_pass = false;
        int i = 0;

        // Are Virtual Stops even enabled?
        if (!USE_VIRTUAL_STOPS)
        {
            return 0;
        }
        
        if (initialized == false || command == "initialize")
        {
            initialized = true;
        }

        // Listen
        if (command == "" || command == "listen")
        {
            int total     = ObjectsTotal(0, -1, OBJ_HLINE);
            int length    = 0;
            color clr     = clrNONE;
            int sltp      = 0;
            ulong ticket  = 0;
            double level  = 0;
            double askbid = 0;
            int polarity  = 0;
            string symbol = "";

            for (i = total - 1; i >= 0; i--)
            {
                name = ObjectName(0, i, -1, OBJ_HLINE); // for example: #1 sl

                if (StringSubstr(name, 0, 1) != "#")
                {
                    continue;
                }

                length = StringLen(name);

                if (length < 5)
                {
                    continue;
                }

                clr = (color)ObjectGetInteger(0, name, OBJPROP_COLOR);

                if (clr != loop_color[0] && clr != loop_color[1])
                {
                    continue;
                }

                string last_symbols = StringSubstr(name, length-2, 2);

                if (last_symbols == "sl")
                {
                    sltp = -1;
                }
                else if (last_symbols == "tp")
                {
                    sltp = 1;
                }
                else
                {
                    continue;	
                }

                ulong ticket0 = StringToInteger(StringSubstr(name, 1, length - 4));

                // prevent loading the same ticket number twice in a row
                if (ticket0 != ticket)
                {
                    ticket = ticket0;

                    if (TradeSelectByTicket(ticket))
                    {
                        symbol     = OrderSymbol();
                        polarity   = (OrderType() == 0) ? 1 : -1;
                        askbid   = (OrderType() == 0) ? SymbolInfoDouble(symbol, SYMBOL_BID) : SymbolInfoDouble(symbol, SYMBOL_ASK);
                        
                        trade_pass = true;
                    }
                    else
                    {
                        trade_pass = false;
                    }
                }

                if (trade_pass)
                {
                    level    = ObjectGetDouble(0, name, OBJPROP_PRICE, 0);

                    if (level > 0)
                    {
                        // polarize levels
                        double level_p  = polarity * level;
                        double askbid_p = polarity * askbid;

                        if (
                            (sltp == -1 && (level_p - askbid_p) >= 0) // sl
                            || (sltp == 1 && (askbid_p - level_p) >= 0)  // tp
                        )
                        {
                            //-- Virtual Stops SL Timeout
                            if (
                                (VIRTUAL_STOPS_TIMEOUT > 0)
                                && (sltp == -1 && (level_p - askbid_p) >= 0) // sl
                            )
                            {
                                // start timeout?
                                int index = ArraySearch(mem_to_ti, ticket);

                                if (index < 0)
                                {
                                    int size = ArraySize(mem_to_ti);
                                    ArrayResize(mem_to_ti, size+1);
                                    ArrayResize(mem_to, size+1);
                                    mem_to_ti[size] = ticket;
                                    mem_to[size]    = (int)TimeLocal();

                                    Print(
                                        "#",
                                        ticket,
                                        " timeout of ",
                                        VIRTUAL_STOPS_TIMEOUT,
                                        " seconds started"
                                    );

                                    return 0;
                                }
                                else
                                {
                                    if (TimeLocal() - mem_to[index] <= VIRTUAL_STOPS_TIMEOUT)
                                    {
                                        return 0;
                                    }
                                }
                            }

                            if (CloseTrade(ticket))
                            {
                                // check this before deleting the lines
                                //OnTradeListener();

                                // delete objects
                                ObjectDelete(0, "#" + (string)ticket + " sl");
                                ObjectDelete(0, "#" + (string)ticket + " tp");
                            }
                        }
                        else
                        {
                            if (VIRTUAL_STOPS_TIMEOUT > 0)
                            {
                                i = ArraySearch(mem_to_ti, ticket);

                                if (i >= 0)
                                {
                                    ArrayStripKey(mem_to_ti, i);
                                    ArrayStripKey(mem_to, i);
                                }
                            }
                        }
                    }
                }
                else if (
                        !PendingOrderSelectByTicket(ticket)
                    || OrderCloseTime() > 0 // in case the order has been closed
                )
                {
                    ObjectDelete(0, name);
                }
                else
                {
                    PendingOrderSelectByTicket(ticket);
                }
            }
        }
        // Get SL or TP
        else if (
            ti > 0
            && (
                command == "get sl"
                || command == "get tp"
            )
        )
        {
            double value = 0;

            name = "#" + IntegerToString(ti) + " " + StringSubstr(command, 4, 2);

            if (ObjectFind(0, name) > -1)
            {
                value = ObjectGetDouble(0, name, OBJPROP_PRICE, 0);
            }

            return value;
        }
        // Set SL and TP
        else if (
            ti > 0
            && (
                command == "set"
                || command == "modify"
                || command == "clear"
                || command == "partial"
            )
        )
        {
            loop_price[0] = sl;
            loop_price[1] = tp;

            for (i = 0; i < 2; i++)
            {
                name = "#" + IntegerToString(ti) + " " + loop_name[i];
                
                if (loop_price[i] > 0)
                {
                    // 1) create a new line
                    if (ObjectFind(0, name) == -1)
                    {
                            ObjectCreate(0, name, OBJ_HLINE, 0, 0, loop_price[i]);
                        ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
                        ObjectSetInteger(0, name, OBJPROP_COLOR, loop_color[i]);
                        ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DOT);
                        ObjectSetString(0, name, OBJPROP_TEXT, name + " (virtual)");
                    }
                    // 2) modify existing line
                    else
                    {
                        ObjectSetDouble(0, name, OBJPROP_PRICE, 0, loop_price[i]);
                    }
                }
                else
                {
                    // 3) delete existing line
                    ObjectDelete(0, name);
                }
            }

            // print message
            if (command == "set" || command == "modify")
            {
                Print(
                    command,
                    " #",
                    IntegerToString(ti),
                    ": virtual sl ",
                    DoubleToStr(sl, (int)SymbolInfoInteger(Symbol(),SYMBOL_DIGITS)),
                    " tp ",
                    DoubleToStr(tp,(int)SymbolInfoInteger(Symbol(),SYMBOL_DIGITS))
                );
            }

            return 1;
        }

        return 1;
    }

    void WaitTradeContextIfBusy()
    {
        if(IsTradeContextBusy()) {
        while(true)
        {
            Sleep(1);
            if(!IsTradeContextBusy()) {
                RefreshRates();
                break;
            }
        }
    }
    return;
    }

    int WindowFindVisible(long chart_id, string term)
    {
    //-- the search term can be chart name, such as Force(13), or subwindow index
    if (term == "" || term == "0") {return 0;}
    
    int subwindow = (int)StringToInteger(term);
    
    if (subwindow == 0 && StringLen(term) > 1)
    {
        subwindow = ChartWindowFind(chart_id, term);
    }
    
    if (subwindow > 0 && !ChartGetInteger(chart_id, CHART_WINDOW_IS_VISIBLE, subwindow))
    {
        return -1;  
    }
    
    return subwindow;
    }

    double attrStopLoss()
    {
        if (USE_VIRTUAL_STOPS)
        {
            return VirtualStopsDriver("get sl", OrderTicket());
        }

        return OrderStopLoss();
    }

    double attrTakeProfit()
    {
        if (USE_VIRTUAL_STOPS)
        {
            return VirtualStopsDriver("get tp", OrderTicket());
        }

    return OrderTakeProfit();
    }

    long attrTicketParent(long ticket)
    {
        int pos = 0;
        int total = 0;
        long retval = 0;
        static long cacheTickets[];
        static long cacheValues[];

        //-- return cached value if possible
        int size = ArraySize(cacheTickets);
        int idx  = -1;

        for (int i = size-1; i >= 0; i--) {
            if (cacheTickets[i] == ticket) {
                return cacheValues[i];
            }  
        }

        if (!OrderSelect((int)ticket, SELECT_BY_TICKET)) {
            retval = ticket;
        }

        //-- check if trade is added to volume
        if (retval == 0) {
            string comment = OrderComment();
            int tagPos     = StringFind(comment, "[p=");

            if (tagPos >= 0) {
                string tag = StringSubstr(comment, tagPos);
                tag        = StringSubstr(tag, 0, StringFind(tag, "]") + 1);
                retval     = (int)StringToInteger(StringSubstr(tag, 3, -1));
            }
        }

        double OP   = OrderOpenPrice();
        datetime OT = OrderOpenTime();
        string S    = OrderSymbol();
        int M       = OrderMagicNumber();
        int T       = OrderType(); 
        double L    = OrderLots();
        int D       = (int)MarketInfo(S, MODE_DIGITS);

        //-- check if trade is partially closed
        if (retval == 0) {
            total = OrdersHistoryTotal();

            for (pos = total-1; pos >= 0; pos--) {
                if (OrderSelect(pos, SELECT_BY_POS, MODE_HISTORY)) {
                    if (OrderOpenTime() < OT) {
                        break;
                    }

                    if (
                        (OrderMagicNumber() == M)
                        && (OrderTicket() < ticket)
                        && (OrderType() == T)
                        && (OrderOpenTime() == OT)
                        && (NormalizeDouble(OrderOpenPrice(), D) == NormalizeDouble(OP, D))
                        && (OrderSymbol() == S)
                    ) {
                        retval = OrderTicket();
                    }
                }
            }
        }

        if (retval > 0) {
            size = ArraySize(cacheTickets);
            ArrayResize(cacheTickets, size + 1);
            ArrayResize(cacheValues,size + 1);
            cacheTickets[size] = ticket;
            cacheValues[size]  = retval;
        }

        // Load the original trade again
        if (!OrderSelect((int)ticket,SELECT_BY_TICKET)) {
            retval = ticket;
        }

        if (retval <= 0) {
            retval = ticket;
        }

        return retval;
    }

    ulong attrTicketPreviousSibling(ulong ticket)
    {
        ulong retval = 0;
        static ulong cacheTickets[];
        static ulong cacheValues[];

        //-- return cached value if possible
        int size = ArraySize(cacheTickets);
        int idx  = -1;

        for (int i = size-1; i >= 0; i--) {
            if (cacheTickets[i] == ticket) {
                return cacheValues[i];
            }  
        }

        if (!OrderSelect((int)ticket, SELECT_BY_TICKET)) {
            retval = ticket;
        }

        if (retval == 0) {
            // 1. Get the parent trade
            long parentTicket = attrTicketParent(ticket);

            for (int pos = OrdersTotal() - 1; pos >= 0; pos--) {
                if (!OrderSelect(pos, SELECT_BY_POS, MODE_TRADES)) {
                    break;
                }

                if ((ulong)OrderTicket() >= ticket) {
                    continue;
                }

                if (attrTicketParent(OrderTicket()) == parentTicket) {
                    retval = OrderTicket();

                    break;
                }
            }

            // when partially closed, look in the history trades also
            if (retval == 0) {
                for (int pos = OrdersHistoryTotal() - 1; pos >= 0; pos--) {
                    if (!OrderSelect(pos, SELECT_BY_POS, MODE_HISTORY)) {
                        break;
                    }

                    if ((ulong)OrderTicket() >= ticket) {
                        continue;
                    }

                    if (attrTicketParent(OrderTicket()) == parentTicket) {
                        retval = OrderTicket();

                        break;
                    }
                }
            }

            // No sibling ticket found, then the sibling ticket
            // is the original ticket
            if (retval == 0.0) retval = ticket;
        }

        if (retval > 0) {
            size = ArraySize(cacheTickets);
            ArrayResize(cacheTickets, size + 1);
            ArrayResize(cacheValues,size + 1);
            cacheTickets[size] = ticket;
            cacheValues[size]  = retval;
        }

        // Load the original trade again
        if (!OrderSelect((int)ticket,SELECT_BY_TICKET)) {
            retval = ticket;
        }

        return retval;
    }

    template<typename DT1, typename DT2>
    bool compare(string sign, DT1 v1, DT2 v2)
    {
            if (sign == ">") return(v1 > v2);
        else if (sign == "<") return(v1 < v2);
        else if (sign == ">=") return(v1 >= v2);
        else if (sign == "<=") return(v1 <= v2);
        else if (sign == "==") return(v1 == v2);
        else if (sign == "!=") return(v1 != v2);
        else if (sign == "x>") return(v1 > v2);
        else if (sign == "x<") return(v1 < v2);

        return false;
    }

    string e_Reason() {return onTradeEventDetector.EventValueReason();}

    string e_ReasonDetail() {return onTradeEventDetector.EventValueDetail();}

    double e_attrClosePrice() {return onTradeEventDetector.EventValuePriceClose();}

    datetime e_attrCloseTime() {return onTradeEventDetector.EventValueTimeClose();}

    string e_attrComment() {return onTradeEventDetector.EventValueComment();}

    datetime e_attrExpiration() {return onTradeEventDetector.EventValueTimeExpiration();}

    double e_attrLots() {return onTradeEventDetector.EventValueVolume();}

    int e_attrMagicNumber() {return (int)onTradeEventDetector.EventValueMagic();}

    double e_attrOpenPrice() {return onTradeEventDetector.EventValuePriceOpen();}

    datetime e_attrOpenTime() {return onTradeEventDetector.EventValueTimeOpen();}

    double e_attrProfit() {return onTradeEventDetector.EventValueProfit();}

    double e_attrStopLoss() {return onTradeEventDetector.EventValueStopLoss();}

    double e_attrSwap() {return onTradeEventDetector.EventValueSwap();}

    string e_attrSymbol() {return onTradeEventDetector.EventValueSymbol();}

    double e_attrTakeProfit() {return onTradeEventDetector.EventValueTakeProfit();}

    int e_attrTicket() {return (int)onTradeEventDetector.EventValueTicket();}

    int e_attrType() {return onTradeEventDetector.EventValueType();}

    template<typename DT1, typename DT2>
    double formula(string sign, DT1 v1, DT2 v2)
    {
            if (sign == "+") return(v1 + v2);
        else if (sign == "-") return(v1 - v2);
        else if (sign == "*") return(v1 * v2);
        else if (sign == "/") return(v1 / v2);

        return false;
    }

    string formula(string sign, string v1, string v2)
    {
        if (sign == "+") return(v1 + v2);
        else {
            double _v1 = StringToDouble(v1);
            double _v2 = StringToDouble(v2);
            
                if (sign == "-") return DoubleToString(_v1 - _v2);
            else if (sign == "*") return DoubleToString(_v1 * _v2);
            else if (sign == "/") return DoubleToString(_v1 / _v2);
        }

        return v1 + v2;
    }

    double formula(string sign, string v1, double v2)
    {
            if (sign == "+") return StringToDouble(v1) + v2;
        else if (sign == "-") return StringToDouble(v1) - v2;
        else if (sign == "*") return StringToDouble(v1) * v2;
        else if (sign == "/") return StringToDouble(v1) / v2;

        return StringToDouble(v1) + v2;
    }

    double formula(string sign, double v1, string v2)
    {
        if (sign == "+") return (v1 + StringToDouble(v2));
        else if (sign == "-") return v1 - StringToDouble(v2);
        else if (sign == "*") return v1 * StringToDouble(v2);
        else if (sign == "/") return v1 / StringToDouble(v2);

        return v1 + StringToDouble(v2);
    }

    double toDigits(double pips, string symbol)
    {
        if (symbol == "") symbol = Symbol();

        int digits   = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
        double point = SymbolInfoDouble(symbol, SYMBOL_POINT);

        return NormalizeDouble(pips * PipValue(symbol) * point, digits);
    }

    double toPips(double digits, string symbol)
    {
        if (symbol == "") symbol = Symbol();

    return digits / (PipValue(symbol) * SymbolInfoDouble(symbol, SYMBOL_POINT));
    }






    class FxdWaiting
    {
        private:
            int beginning_id;
            ushort bank  [][2][20]; // 2 banks, 20 possible parallel waiting blocks per chain of blocks
            ushort state [][2];     // second dimention values: 0 - count of the blocks put on hold, 1 - current bank id

        public:
            void Initialize(int count)
            {
                ArrayResize(bank, count);
                ArrayResize(state, count);
            }

            bool Run(int id = 0)
            {
                beginning_id = id;

                int range = ArrayRange(state, 0);
                if (range < id+1) {
                    ArrayResize(bank, id+1);
                    ArrayResize(state, id+1);

                    // set values to 0, otherwise they have random values
                    for (int ii = range; ii < id+1; ii++)
                    {
                    state[ii][0] = 0;
                    state[ii][1] = 0;
                    }
                }

                // are there blocks put on hold?
                int count = state[id][0];
                int bank_id = state[id][1];

                // if no block are put on hold -> escape
                if (count == 0) {return false;}
                else
                {
                    state[id][0] = 0; // null the count
                    state[id][1] = (bank_id) ? 0 : 1; // switch to the other bank
                }

                //== now we will run the blocks put on hold

                for (int i = 0; i < count; i++)
                {
                    int block_to_run = bank[id][bank_id][i];
                    _blocks_[block_to_run].run();
                }

                return true;
            }

            void Accumulate(int block_id = 0)
            {
                int count   = ++state[beginning_id][0];
                int bank_id = state[beginning_id][1];

                bank[beginning_id][bank_id][count-1] = (ushort)block_id;
            }
    };
    FxdWaiting fxdWait;



    //+------------------------------------------------------------------+
    //| END                                                              |
    //| Created with fxDreema EA Builder           https://fxdreema.com/ |
    //+------------------------------------------------------------------+

    /*<fxdreema:eNrtHWtT28b2rzC0t5N0klSrt51OZ8BAygwELob09pNGltegIEuuJCehHf77PWcf0uoFNoiQFJhMsLW7533OnrMP4Q+d4T/ZkJDhZpDEMQ3yMImzzbf+kEBDONTgk4E9rOHmLKTRdPNtBkM2d3b3ts4OTvGbPdzMkmUaUPwCcIh4mPvpOc3FQ33z7XU4JOtD09ugmQyavj40oxua0ROnBoNmrg/NbINmMWjW+tCsNmg2g2avD81pgzZg0Jz1obnd0NyetOAwaIOeoLncetd1Bh3ANe0Xn3IjIeQOAI1WgNyGiX4HgGYrQG54xLgDQLsVINcIMe8A0GkFKJRi3QGg2wqQWyCx1weoa20AdbCl62v2fBIlwSUPqwMMq6h4nSASlwXePE0i1mzhs8Fw812aLBeHyZRhAELO8bv4/E5+1oabzEDh9/hqPkkiOQDpYw/El3HxRQ4Bo95eXmVH6ZhGiDkbmkBlkl8AyYwAJMoPY5qKttMwuMSPQO80zPxJREEuE5gfmGzol5ymfN7Qhv9cM/bDqepSADLMvGCZ5clcDnSlYLjIGNVZTucCzxy4iTwOBr6+T47SKU0ZsTA5bS781J9TwAtgkySdZgp/AGoRwnRW0AhiywI/ktKJk3TuR1J4GUVYeZIyBgyuIEk6zjPlZ6P4zBWb5X6+ZMN0YTJJnMxm2FXjgpv6uV9Qds265GHOKdFNZGsjT/0p/SVB7l6AVn5BnbwUlAIwJh6BAAZEdJYjfGIiBgPAJQv2XdMQPvT47Ie5ZBzk/slPQ1SYoh4QX7LMF8s8UyGH8AzHEU45FV8ZWMATZFI+IAM0aj+4RLuMp6+DJEpS4Sc/bA1Gg709YaxFC0jtB2l6MzCu159peH6Rq6IhZukMHphU6pcUEx3tE0X0OsuvuPj4OJ4ItHqTic9g4EFSsFkaJhAXxtMwYIr3wpPxvjA0FYIt/BFaFzQNk2IoMYPhEJ56ymOAvbVYRCGdHqehmFGA2+OT/dGuNzo4Gu92+SM8Oy7hgBiOd0/2j3a80dnJye77UyHL8UU4y1WnQuMdHUGX0en+0ftSJFzDQTIHu5Yx6stv4sNJmzAImkm0pB77v0UQ0rw/yHYYa2m3EIFNQZpk2edwiqFF8Z12XZMiGcVRXnNYv5FJ7yEywfBRAnaEifNDhybOQS9hB0z3p/P8raX9FE+yxdtfJ+lvGHtuDzuWVY06rvVtRJ29vZ3R1uAuUaclsoCOcyA/Psevojh4jjCPEGEG33mEMZ4jzGDdCEMs7QmGGLMrxHDG+jVLsx+zPEjOIbpFRyffi1kONzmtN9ufVp3idKsv+9PuZ3+zGZ1MJ18xsba6bJKResdpBhEe+1l26H85Dec0e8Doa/Vg5miMR3FAga1tP/1ODB1ljERvQO6wMeFk32jzbtXkDf0bqSUnGtVd4yuavN25MmMKPdSXX1rXV+D3hyRazqlcknGQx8iPRdJWtI/Dv9kTkIn2hkivKdtOwuyyUW7xZtkEQ/U3zNSJIdvAWgMa85UodC5Ng2RSPPS2FUJcOWIb/UEZJpMXlPFUpbWHzE5h9obUDqDshV/o9MSHzOcsDnMpKxOHa0QmymWnHRpxnyjW5FDV8/kpLrBkxwnXEdCrybHz+eH5PoAO/eggybMacS7vcLiM8nARXR3FB0mWqbWjrtV7HKfJLKym0A7vszWdIooKEE7HoNahAqNC6gkF/22B4FSau2gghm53M2vILif0E8Q1ufI48yP+mcPYCydJJwydSXsHQt18QtP8FsEW/ToQ6oyiA3+SLIMLmtJucHa140GY5dIyySv9lfHKfGW9sktZl127eGWox/SvbT+jLQiJaC5VAaMNQGVXRreqQheNXaht6ZFnC4jeB+E8zNXIAsPHEKURr4wtJs4pMa03H4eLrBI60FqLRu7pRRnJfMqypKJr3U6PhQAgkEi3nUayUy8xYYWKk2Fd9Iq1ytJNeKe94lVD2A2IMf3xLym3ojZ1
    Vzo0Fa5Xmm9Q+aCl4/igJiEdlV52+2pqR7yLnvGupnjEPO0Z82qqBx/c/VLsAAG1705HIo+A5zv+lZpxuuzh78kyzeoyRSBhvMyp2h+zR2hoYUeT7OSQmrdxo4vUCCk7FX2KaUjDbB3yBHVDVRM5OGvI/bncxdK0YWlW2Djy42lE93fqHGDboZ9e0koYHKiD8NMME/L6pMi6JPMFuEuc/0l5IixBuLX2Q+DzQu1g1zqA1NXmOnyUf2XbtyCywMA0UZ/7K13GFMQ9bZFdYT8SvVEqQV2204u4IBuQb1X7mEwUjYzpSqs69A9KL7Ma0qJRGmGhLHVkYYw1YXKkDYusNHMZtDZfhgukaSpQm7iIgmJBlwF9jqNwsfDPaW2Z4/AK5DuXiS0uXA6Hh1vvx1uHZ+Pxlqd7mmRuK02TzyOsM7aXV8LfgijdZrLvvT61e6hPbbaT+z75/NClqaXsi2rd+6K4klX2sXrdL3UYrxsxZ/bGgnZQK2hd7WHWcMiaBa2muRqPe2pBy1d38KejrGW783gU4Q6lLXCZ0iAvlxqd592MFXYzfn3eL63HK+eJ7mZYfDcjqu2XrnZOQ6+f0xhoT2A7w32OMY8SY0zynccY98nHGJOsHWOMJxljBl9zy3TwvGV6wxxXS7d1W3uiW6ZEfzJHe4t1jvvusAIN+7OjBQVD//cd8dWROX7EVx6BWfGAr6XVD/haT/SALzFuPIjQkU2i6P0gAPpzb4v/VnY+a4B4lrNq7gYs/txv6oarkUTZo1U2jrqI6hSoLk5n+NOPy0wuH/wilrttXA3IllEut9g+FUj9c+otGF5ve/wQ0aKP03CAZA9cexn538tZDJMVEijgjVKrN3q+WTuOQZxv5gSS6zZXr+6YzhXe3Xn0jRiPP2dyBe76wUV1F04Zio2jSnD4TS5al+O25hiAlJG4G1tvVnbwSLFYVMWLJwGSmMrF6Ta8uhxT4sQDmVqnp3NabyCk/1DQxwlEZHR0QYPLMyVaPkLaoD1A2mAJ1ja4mjZeLOOU+lH4N53enjmYtUP6uAT1RDOHziOM7jcRWrC8QsqbO2Idu1lIQrlJJTEEUbpD6eI4jC8fwll7OUcJZI6iJKM80X+s3Spthd0qrScftgXHPPvP1kz/zXpNPfhGkgDTdvWJufYWlqKw+zi0/aTqa/u5vn6w+tqpX2V7uvW18++vr+1qfR3JI7QNkkBRP78mfRXYpF5g4xHCByqvnSdZXutleS2VerPbm/XiWvs3F9fuc3HdU3H9a2dxrTeK68LLH6G0dp9L64crrR1Sy8qNJ5s0DJ5L6/s76+C5tP76pbVTu2GuD7Tn0hrmzK92nqK4n3dPyzf5VeLvJFVVqL357LIzeKDC9J7mGbCfNvM02M9Dvd+p83Vppi3UcCplbOgsbcPD/huHNMsgxrcf9geqjyYfRxd+mo+Xkz/CeMpPlQtzGfDmJBXGjvuzUCe+3z3xTvbf/X7qnR0f754IrULP/6lXzvmjP6Wlm8V8NPnICN1LeOIINLyjSXoe+gpJRY+RImCYhd4l/FV0qCC1m7wVW2yw4j0G6HDgT2iUKag+0HTqx77kptKlMeX56eW7lN93EXSVnVWMmgAOHTpQ6UVjgcRlOP64CPPiQKbo0gANzDLERJ7/L1cYbFHekwdemkB5Yk3s5++XeF+VVG7aENmI91OK26G7h8enf3oftg7OdlUu5Nsgd/9ahvmVyoTewgRpMFGOuycPejcP+i08GDJGvvjPy+qGNmPEeKzjEE0mjQ5Oqvwat/BryvYXP74UJUOmMmz2c3QXYga5aYN2dbbNbt2at/BqCVJRtcpiCqPS+srrcJ38WSup1bqFVVuy+mOTVbsfleoNlarLAqszbHcr1L6FS6eaATHanCZ3MNvlMCF7+F8Xa5juiWalZluRBWclnTm3cOO2cOM+AjfuSty09+o/kSZ9nZhnWdPul4fOpiG2r7TYUxSQpHqTEF/SUn52lM+uAmegPCea+kXF
    TNSdKaLiJipyYimQia1+cdQvbq9VrlMoZYWSgVRLBtv9Vha1ZzPL/mrLUvwaMAgpD+Nz5cY6kugHefiJel2uh0Bhyv1Ig9yL5V1yvOEzT5L8YiPws4sN/Y1W75pfLaTR0y8LmuYyBQ/AvTzIOc+XYp0JcB3+96CYgkHzQExKfUyC2TYEsR3DIfCPqF3ATcPZVVeXuX8eBh7YWcovghi6K7edwiwERXtROEn99MorVt8qcQAvoMueLFh09UPbgqCWepm8nQ1+qAkqFkkIc3m6FHZlyD8dII1pliZzee//jcZffqCjsVZeiCD+QkB9kMMH1YfZ4jEp3wFcG+jKgTeMvOaxbpnBxB6m+dKPQJhJsUIfJ8UuntrKXo/APII7MkoRQVAQ0DmNg6sWINin1u6lNKq/DaDexZ9W3gaA0qafICRkaBjSrnJpw4OiNbgKQKXyJpyIt9gco/t72QIsb+qx+F40G2WzCFy8ATOZnIIpgPYvks9eeUevGOrg8q6/uPCSNMRkp7h6BfSeJovTZDvJ2dRUzH+AIs7Lkxvo7/UyvbwtWJ5kaJbyLo+iiiNmeQruXzgazYI0XEiKxAxmiXyu082v+fPGS7MaRLV1alBl4M3GfHWSsBxwLUGGxu6GFcpsUFBrvzdy+RcFKoeXvfIdKE2tNOu0dUjAaq8KYQMqkDaRsLvz15VdX1FCNKhq9FiTJrs6HijSWuTEVHTdnFp5RqoVMGoFXZ3a7p5t9j1NlpOIrmHfMiVRBF0pRxrC6+jXIzE81/EhCknl8ejvVgkp/3xA17xdJj2WyFWKW2kWRy2urMLsONA4zRci3cBH5G3tQAGury1ovMF2jzZegGe97LIReLSjPhITUYMHfXUenCoPZoMJ3Rg0mNCcFib4BknVn1ZkwmhjwlidCavKhO2uxIT1tnm0Y7TMNw64+63DgNnGgHlnBgYmqTFAmKIqDBCnbkrVBH4l0nk+jm+GY99RFdf/B83APXQ=
    :fxdreema>*/
