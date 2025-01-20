// Adaptive RSI levels based on performance
class AdaptiveRSI {
    private:
        double successfulBuyLevels[];  // Store RSI levels of profitable buy trades
        double successfulSellLevels[]; // Store RSI levels of profitable sell trades
        int maxHistory = 50;           // Maximum number of levels to store
        
    public:
        void Initialize() {
            ArrayResize(successfulBuyLevels, 0);
            ArrayResize(successfulSellLevels, 0);
        }
        
        void AddSuccessfulLevel(bool isBuy, double rsiLevel) {
            double &levels[] = isBuy ? successfulBuyLevels : successfulSellLevels;
            
            // Add new level
            int size = ArraySize(levels);
            ArrayResize(levels, size + 1);
            levels[size] = rsiLevel;
            
            // Keep only last maxHistory entries
            if (size > maxHistory) {
                for(int i = 0; i < size - 1; i++) {
                    levels[i] = levels[i + 1];
                }
                ArrayResize(levels, maxHistory);
            }
        }
        
        double GetOptimalBuyLevel() {
            int size = ArraySize(successfulBuyLevels);
            if(size == 0) return 50.0; // Default level
            
            double sum = 0;
            for(int i = 0; i < size; i++) {
                sum += successfulBuyLevels[i];
            }
            return sum / size;
        }
        
        double GetOptimalSellLevel() {
            int size = ArraySize(successfulSellLevels);
            if(size == 0) return 50.0; // Default level
            
            double sum = 0;
            for(int i = 0; i < size; i++) {
                sum += successfulSellLevels[i];
            }
            return sum / size;
        }
};